class Comment < ApplicationRecord
  belongs_to :quiz
  belongs_to :user
  belongs_to :game, optional: true

  enum vote: { down: -1, neutral: 0, up: 1 }
  validates :vote, inclusion: { in: [ -1, 0, 1 ] }
  validates :user_id, uniqueness: { scope: :quiz_id }
end
