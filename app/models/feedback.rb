class Feedback < ApplicationRecord
  belongs_to :quiz
  belongs_to :user
  after_create_commit  -> { broadcast_prepend_to [ quiz, :feedbacks ], target: "feedbacks" }
  after_update_commit  -> { broadcast_replace_to [ quiz, :feedbacks ] }
  after_destroy_commit -> { broadcast_remove_to  [ quiz, :feedbacks ] }
end
