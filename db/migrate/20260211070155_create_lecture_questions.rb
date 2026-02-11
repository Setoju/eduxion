class CreateLectureQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :lecture_questions do |t|
      t.text :question_text
      t.text :answer_text
      t.integer :position

      t.references :lesson, null: false, foreign_key: true

      t.timestamps
      t.index [:lesson_id, :position]
    end
  end
end
