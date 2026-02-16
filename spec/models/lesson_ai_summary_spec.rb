require 'rails_helper'

RSpec.describe LessonAiSummary, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:summary_text) }
    it { should validate_numericality_of(:chunk_index).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:lesson) }
  end

  describe 'default scope' do
    it 'orders lesson AI summaries by chunk index' do
      lesson = create(:lesson)
      summary1 = create(:lesson_ai_summary, lesson: lesson, chunk_index: 2)
      summary2 = create(:lesson_ai_summary, lesson: lesson, chunk_index: 1)

      expect(LessonAiSummary.all).to eq([summary2, summary1])
    end
  end

  describe 'lesson AI summary creation' do
    let(:lesson) { create(:lesson) }
    let(:lesson_ai_summary) { create(:lesson_ai_summary, lesson: lesson) }

    context 'with valid attributes' do
      it 'is valid with valid attributes' do
        expect(lesson_ai_summary).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without summary_text' do
        lesson_ai_summary.summary_text = nil
        expect(lesson_ai_summary).not_to be_valid
        expect(lesson_ai_summary.errors[:summary_text]).to include("can't be blank")
      end

      it 'is invalid with a negative chunk_index' do
        lesson_ai_summary.chunk_index = -1
        expect(lesson_ai_summary).not_to be_valid
        expect(lesson_ai_summary.errors[:chunk_index]).to include("must be greater than or equal to 0")
      end
    end
  end
end
