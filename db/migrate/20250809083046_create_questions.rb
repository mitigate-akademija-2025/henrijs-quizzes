class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.string :type, null: false, default: "ChoiceQuestion"
      t.integer :points, null: false, default: 1
      t.integer :max_selections, null: false, default: 1
      t.string  :image_path
      t.integer :position
      t.references :quiz, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end

    add_index :questions, :type
  end
end
