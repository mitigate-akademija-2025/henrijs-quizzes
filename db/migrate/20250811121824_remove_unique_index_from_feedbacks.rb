class RemoveUniqueIndexFromFeedbacks < ActiveRecord::Migration[8.0]
  def up
    if index_exists?(:feedbacks, [ :quiz_id, :user_id ], unique: true)
      remove_index :feedbacks, column: [ :quiz_id, :user_id ]
    end
  end

  def down
    add_index :feedbacks, [ :quiz_id, :user_id ], unique: true
  end
end
