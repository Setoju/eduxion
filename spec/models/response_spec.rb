require 'rails_helper'

RSpec.describe Response, type: :model do
  let (:response) { build(:response) }

  describe 'validations' do
    it { should validate_presence_of(:content) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_one(:mark) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let(:lesson) { create(:lesson) }
    let(:quiz) { create(:lesson, :with_quiz) }
    let(:question) { create(:question) }
    let(:quiz_question) { quiz.questions.first || create(:question, lesson: quiz) }
    let!(:response1) { create(:response, user: user, responseable: lesson) }
    let!(:response2) { create(:response, user: user, responseable: question) }
    let!(:quiz_response) { create(:response, user: user, responseable: quiz) }
    let!(:quiz_question_response) { create(:response, user: user, responseable: quiz_question) }

    it 'returns responses for a specific user' do
      expect(Response.for_user(user)).to include(response1, response2)
    end

    it 'returns responses for a specific lesson' do
      expect(Response.for_lesson(lesson)).to include(response1)
      expect(Response.for_lesson(lesson)).not_to include(response2)
    end

    it 'returns responses for specific questions' do
      expect(Response.for_questions([question])).to include(response2)
      expect(Response.for_questions([question])).not_to include(response1)
    end

    it 'returns responses for a specific lesson and its questions' do
      expect(Response.for_lesson_and_questions(quiz)).to include(quiz_response, quiz_question_response)
      expect(Response.for_lesson_and_questions(quiz)).not_to include(response1, response2)
    end
  end

  describe 'response creation' do
    context 'with valid attributes' do
      it 'is valid with valid attributes' do
        expect(response).to be_valid
      end
    end

    context 'with invalid attributes' do
      it 'is invalid without content' do
        response.content = nil
        expect(response).not_to be_valid
        expect(response.errors[:content]).to include("can't be blank")
      end
    end
  end
end
