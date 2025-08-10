class Game < ApplicationRecord
  belongs_to :quiz
  belongs_to :user, optional: true
  has_many :guesses, dependent: :destroy
  before_validation :ensure_share_token, on: :create

  def to_param = share_token

  def calculate_score
    score = 0

    quiz.questions.each do |question|
      correct_ids = question.options.where(correct: true).pluck(:id).sort
      chosen_ids  = guesses
                    .where(option_id: question.options.pluck(:id))
                    .pluck(:option_id)
                    .sort

      score += 1 if correct_ids == chosen_ids
    end

    score
  end

  private

  def ensure_share_token
    self.share_token ||= SecureRandom.hex(16)
  end
end
