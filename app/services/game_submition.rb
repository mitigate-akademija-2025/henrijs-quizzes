class GameSubmission
  def initialize(quiz:, user:, started_at:, choice_params:, text_params:)
    @quiz          = quiz
    @user          = user
    @started_at    = started_at
    @choice_params = choice_params || {}
    @text_params   = text_params   || {}
  end

  def call
    ActiveRecord::Base.transaction do
      build_game!
      persist_choice_guesses!
      persist_text_guesses!
      finish_and_score!
    end
    @game
  end

  private

  def build_game!
    @game = @quiz.games.build(
      user: @user,
      started_at: @started_at
    )
    @game.save!
  end

  def persist_choice_guesses!
    # preload options once to avoid N+1
    @quiz.questions.includes(:options).each do |question|
      next unless question.is_a?(MultipleChoiceQuestion)

      raw = @choice_params[question.id.to_s]
      selected = normalize_ids(raw)

      allowed = question.options.ids
      selected &= allowed                          # keep only options of this question

      if question.max_selections.present?
        selected = selected.first(question.max_selections)
      end

      selected.each do |option_id|
        @game.guesses.create!(
          type: "ChoiceGuess",
          question_id: question.id,
          option_id: option_id
        )
      end
    end
  end

  def persist_text_guesses!
    @quiz.questions.each do |question|
      next unless question.is_a?(TextQuestion)

      submitted = @text_params[question.id.to_s].to_s
      next if submitted.strip.empty?

      @game.guesses.create!(
        type:        "TextGuess",
        question_id: question.id,
        answer_text: submitted
      )
    end
  end

  def finish_and_score!
    @game.update!(
      score:       @game.calculate_score,
      finished_at: Time.current
    )
  end

  def normalize_ids(value)
    ids = []
    Array(value).each do |v|
      i = v.to_i
      ids << i unless i.zero?
    end
    ids.uniq
  end
end
