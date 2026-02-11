class LectureQuestion < ApplicationRecord
    belongs_to :lesson

    validates :question_text, presence: true
    validates :answer_text, presence: true
    validates :position, numericality: { greater_than_or_equal_to: 0 }

    default_scope { order(:position) }
end
