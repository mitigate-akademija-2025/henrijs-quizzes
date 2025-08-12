class Guess < ApplicationRecord
  self.inheritance_column = :type
  belongs_to :game
  belongs_to :question
  belongs_to :option, optional: true
end

class ChoiceGuess < Guess
  validates :option_id, presence: true
  validates :answer_text, absence: true
  validates :option_id, uniqueness: { scope: :game_id }
end

class TextGuess < Guess
  validates :option_id, absence: true
  validates :answer_text, presence: true
  validates :question_id, uniqueness: { scope: :game_id }
end
