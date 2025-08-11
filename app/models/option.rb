class Option < ApplicationRecord
  belongs_to :question, inverse_of: :options
  validates :content, presence: true
end
