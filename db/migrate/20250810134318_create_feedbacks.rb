class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :comment
      t.timestamps
    end

    add_index :feedbacks, [ :quiz_id, :user_id ], unique: true
  end
end
