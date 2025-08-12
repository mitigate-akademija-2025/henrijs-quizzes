class Question < ApplicationRecord
  belongs_to :quiz
  has_many :guesses, dependent: :destroy
  has_many :options, dependent: :destroy

  validates :content, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than: 0 }
end

class MultipleChoiceQuestion < Question
  validates :max_selections, numericality: { only_integer: true, greater_than: 0 }
end

class TextQuestion < Question
  validates :max_selections, absence: true
end
