class Quiz < ApplicationRecord
  has_many :questions, inverse_of: :quiz, dependent: :destroy
  has_many :games, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  belongs_to :user
  accepts_nested_attributes_for :questions, allow_destroy: true
  validates :title, presence: true
  after_create_commit  -> { broadcast_prepend_to "quizzes" }
  after_update_commit  -> { broadcast_replace_to "quizzes" }
  after_destroy_commit -> { broadcast_remove_to  "quizzes" }
end
