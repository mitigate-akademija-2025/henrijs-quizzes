class Guess < ApplicationRecord
  self.inheritance_column = :type
  belongs_to :game
  belongs_to :question
  belongs_to :option, optional: true
end
