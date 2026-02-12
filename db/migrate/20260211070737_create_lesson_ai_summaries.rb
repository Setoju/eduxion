class CreateLessonAiSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :lesson_ai_summaries do |t|
      t.integer :chunk_index
      t.text :summary_text

      t.references :lesson, null: false, foreign_key: true

      t.timestamps
    end
  end
end
