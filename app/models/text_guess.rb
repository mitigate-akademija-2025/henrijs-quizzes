class TextGuess < Guess
  validates :option_id, absence: true
  validates :answer_text, presence: true
  validates :question_id, uniqueness: { scope: :game_id }
end
