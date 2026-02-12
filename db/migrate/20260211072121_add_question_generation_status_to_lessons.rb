class AddQuestionGenerationStatusToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :question_generation_status, :string, default: "disabled"
    add_column :lessons, :content_checksum, :string
  end
end
