class ChoiceGuess < Guess
  validates :option_id, presence: true
  validates :answer_text, absence: true
  validates :option_id, uniqueness: { scope: :game_id }
end
