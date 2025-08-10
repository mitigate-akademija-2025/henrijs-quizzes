class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :game, null: false, foreign_key: true
      t.references :quiz, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.text :comment
      t.integer :vote, null: false, default: 0
      t.timestamps
    end

    add_index :feedbacks, [ :game_id, :user_id ], unique: true
    add_check_constraint :feedbacks, "vote IN (-1, 0, 1)", name: "vote_in_range"
  end
end
