class Question < ApplicationRecord
  has_many :options, inverse_of: :question, dependent: :destroy
  belongs_to :quiz, inverse_of: :questions
  accepts_nested_attributes_for :options, allow_destroy: true
  validates :content, presence: true
end
