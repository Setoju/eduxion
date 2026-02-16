require 'rails_helper'

RSpec.describe LectureQuestionsGeneratorJob, type: :job do
  let (:course) { create(:course) }
  let (:topic) { create(:topic, course: course) }
  let (:lesson) { create(:lesson, :with_text, topic: topic) }

  describe "#perform" do
    it "generates questions for a lesson" do
      expect {
        LectureQuestionsGeneratorJob.new.perform(lesson.id)
      }.to change { LectureQuestion.count }
    end

    it "does not generate duplicate questions for the same lesson" do
      initial_count = LectureQuestion.count
      Lessons::AiSummary::TextSummarizer.new(lesson).call
      expect(LectureQuestion.count).to eq(initial_count)
    end
  end
end
