require 'rails_helper'

RSpec.describe LectureQuestion, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:question_text) }
    it { should validate_numericality_of(:position).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should belong_to(:lesson) }
  end

  describe 'default scope' do
    it 'orders lecture questions by position' do
      lesson = create(:lesson)
      question1 = create(:lecture_question, lesson: lesson, position: 2)
      question2 = create(:lecture_question, lesson: lesson, position: 1)

      expect(LectureQuestion.all).to eq([question2, question1])
    end
  end

  describe 'lecture question creation' do
    let(:lesson) { create(:lesson) }
    let(:lecture_question) { create(:lecture_question, lesson: lesson) }

    context 'with valid attributes' do
      it 'is valid with valid attributes' do
        expect(lecture_question).to be_valid
      end

      it 'belongs to a lesson' do
        expect(lecture_question.lesson).to eq(lesson)
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without question_text' do
        lecture_question.question_text = nil
        expect(lecture_question).not_to be_valid
        expect(lecture_question.errors[:question_text]).to include("can't be blank")
      end

      it 'is invalid with a negative position' do
        lecture_question.position = -1
        expect(lecture_question).not_to be_valid
        expect(lecture_question.errors[:position]).to include("must be greater than or equal to 0")
      end
    end
  end
end
