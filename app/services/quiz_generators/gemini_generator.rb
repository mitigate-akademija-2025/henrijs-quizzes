require "faraday"
require "json"

module QuizGenerators
    class GeminiGenerator
        ENDPOINT = "https://generativelanguage.googleapis.com"

        # Default order if ENV["GEMINI_MODELS"] is not set
        DEFAULT_MODELS = [
        "gemini-2.5-flash",
        "gemini-2.5-flash-lite",
        "gemini-2.5-pro",
        "gemini-2.0-flash",
        "gemini-2.0-flash-lite",
        "gemini-1.5-flash"
        ].freeze

        def initialize(api_key: ENV["GEMINI_API_KEY"], models: env_models)
        @api_key = api_key or raise "GEMINI_API_KEY not set"
        @models  = Array(models).presence || DEFAULT_MODELS

        @http = Faraday.new(url: ENDPOINT) do |f|
            f.request :json
            f.response :json, content_type: /\bjson$/
            f.options.timeout      = 30
            f.options.open_timeout = 5
            f.adapter Faraday.default_adapter
        end
        end

        # description -> Ruby Hash { title:, description:, questions:[...] }
        def generate_from_description(description)
        errors = []

        @models.each do |model|
            begin
            return call_model(model, description)
            rescue => e
            Rails.logger.warn("[GeminiGenerator] #{model} failed: #{e.message}")
            errors << "#{model}: #{e.message}"
            # Tiny backoff for transient errors
            sleep 0.4 if transient?(e)
            end
        end

        raise "All Gemini models failed: #{errors.join(' | ')}"
        end

        private

        # Reads GEMINI_MODELS (comma-separated), or falls back to DEFAULT_MODELS
        def self.env_models
        raw = ENV["GEMINI_MODELS"]
        return nil if raw.nil?

        raw.split(",").map { |m| m.strip }.reject(&:empty?).uniq
        end

        def env_models = self.class.env_models

        def call_model(model, description)
            body = {
                contents: [
                {
                    parts: [
                    {
                        text: <<~PROMPT
                            You are a quiz author. Produce a quiz that matches the user's description.

                            Rules:
                            - Use ONLY the provided response schema (do NOT add extra fields).
                            - For ChoiceQuestion: include an 'options' array (>= 2 items). Prefer exactly one correct option unless the user asks for multiple correct.
                            - For TextQuestion: INCLUDE an 'options' array listing all acceptable answers. Mark **every** option with "correct": true.
                            - Keep questions concise and unambiguous. Avoid trivia that requires external context.
                            - Generate at leat 10 questions, both TExtQuestions and ChoiceQuestions if not specified differently

                            User description:
                            #{description}
                        PROMPT
                    }
                    ]
                }
                ],
                generationConfig: {
                response_mime_type: "application/json",
                response_schema: quiz_schema
                }
            }

            resp = @http.post do |req|
                req.url "/v1alpha/models/#{model}:generateContent"
                req.headers["x-goog-api-key"] = @api_key
                req.headers["Content-Type"]   = "application/json"
                req.body = body
            end

            unless resp.success?
                code = resp.status
                message = resp.body.is_a?(Hash) ? resp.body["error"] || resp.body : resp.body
                raise "HTTP #{code} #{message}"
            end

            text = resp.body.dig("candidates", 0, "content", "parts", 0, "text")
            raise "Empty response body" if text.nil? || text.strip.empty?

            data = JSON.parse(text, symbolize_names: true)
            normalize_text_question_options!(data)
            data
        end


        def normalize_text_question_options!(data)
            Array(data[:questions]).each do |q|
                next unless q[:type] == "TextQuestion"

                q[:options] = Array(q[:options]).presence || []
                q[:options].each { |opt| opt[:correct] = true }
            end
        end


        def transient?(error)
            msg = error.message
            # crude detection: timeouts, 429, 5xx
            msg.include?("Timeout") || msg.include?("HTTP 429") || msg =~ /HTTP 5\d{2}/
        end

        def quiz_schema
        {
            type: "object",
            properties: {
            title:       { type: "string" },
            description: { type: "string" },
            questions: {
                type: "array",
                items: {
                type: "object",
                properties: {
                    type:          { type: "string", enum: [ "ChoiceQuestion", "TextQuestion" ] },
                    content:       { type: "string" },
                    points:        { type: "integer" },
                    maxSelections: { type: "integer", nullable: true },
                    imagePath:     { type: "string",  nullable: true },
                    options: {
                    type: "array",
                    nullable: true,
                    items: {
                        type: "object",
                        properties: {
                        content: { type: "string" },
                        correct: { type: "boolean" }
                        },
                        required: [ "content", "correct" ],
                        propertyOrdering: [ "content", "correct" ]
                    }
                    }
                },
                required: [ "type", "content", "points" ],
                propertyOrdering: [ "type", "content", "points", "maxSelections", "imagePath", "options" ]
                }
            }
            },
            required: [ "title", "description", "questions" ],
            propertyOrdering: [ "title", "description", "questions" ]
        }
        end
    end
end
