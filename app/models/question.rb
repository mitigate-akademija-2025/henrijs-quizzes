class Question < ApplicationRecord
  belongs_to :quiz
  has_many :guesses, dependent: :destroy
  has_many :options, dependent: :destroy

  validates :content, presence: true
  validates :points, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true, greater_than: 0 }
end
