class Game < ApplicationRecord
  belongs_to :quiz
  belongs_to :user, optional: true
  has_many :guesses, dependent: :destroy
  before_validation :ensure_share_token, on: :create

  def to_param = share_token

  def calculate_score
    questions = quiz.questions.includes(:options)
    game_guesses = guesses.includes(:option).to_a
    guesses_by_qid = game_guesses.group_by(&:question_id)

    total_score = 0

    questions.each do |question|
      case question
      when ChoiceQuestion
        # Correct set
        correct_option_ids = question.options
                                     .select { |opt| opt.correct }
                                     .map(&:id)
                                     .sort

        # Chosen set
        chosen_option_ids = guesses_by_qid.fetch(question.id, [])
                                          .map(&:option_id)
                                          .sort

        if chosen_option_ids == correct_option_ids
          total_score += question.points
        end

      when TextQuestion
        # model layer ensures that at most one text guess is possible
        text_guess = guesses_by_qid.fetch(question.id, []).find { |g| g.is_a?(TextGuess) }

        if text_guess
          submitted_text = normalize_answer(text_guess.answer_text)
          # treat all options as acceptable answers
          acceptable_texts = question.options.map { |opt| normalize_answer(opt.content) }

          total_score += question.points if acceptable_texts.include?(submitted_text)
        end

      else
        # unknown question type
      end
    end

    total_score
  end

  private

  def ensure_share_token
    self.share_token ||= SecureRandom.hex(16)
  end

  def normalize_answer(answer)
    answer.to_s.strip.downcase.gsub(/\s+/, " ")
  end
end
