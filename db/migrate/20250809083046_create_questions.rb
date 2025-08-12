class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.string :type, null: false, default: "MultipleChoiceQuestion"
      t.integer :points, null: false, default: 1
      t.integer :max_selections, null: false, default: 1
      t.string  :image_path
      t.integer :position
      t.references :quiz, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    add_index :questions, :type
    add_index :questions, [ :quiz_id, :type ], name: "index_questions_on_quiz_and_type"
    add_index :questions, [ :quiz_id, :position ],
          unique: true,
          where: "position IS NOT NULL",
          name: "idx_questions_quiz_position_unique"
  end
end
