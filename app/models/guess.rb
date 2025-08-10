# app/models/guess.rb
class Guess < ApplicationRecord
  belongs_to :game
  belongs_to :option
  has_one :question, through: :option

  validates :game_id, :option_id, presence: true

  validates :option_id, uniqueness: { scope: :game_id }
end
