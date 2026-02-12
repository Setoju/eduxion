class LessonAiSummary < ApplicationRecord
  belongs_to :lesson

  validates :summary_text, presence: true
  validates :chunk_index, numericality: { greater_than_or_equal_to: 0 }

  default_scope { order(:chunk_index) }
end
