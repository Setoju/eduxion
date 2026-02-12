class AddQuestionGenerationStatusToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :question_generation_status, :string, default: "pending"
    add_column :lessons, :content_checksum, :string
  end
end
