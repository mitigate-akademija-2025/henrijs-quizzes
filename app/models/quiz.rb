class Quiz < ApplicationRecord
  belongs_to :user
  has_many :questions, dependent: :destroy
  has_many :games, dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true
  validates :title, presence: true
  has_many :feedbacks, dependent: :destroy
  def vote_score
    feedbacks.sum(:vote)
  end
end
