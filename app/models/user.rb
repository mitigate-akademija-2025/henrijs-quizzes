class User < ApplicationRecord
  devise :confirmable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :lockable
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  has_many :quizzes, dependent: :destroy
end
