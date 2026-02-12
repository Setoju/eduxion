class LectureQuestionsGeneratorJob < ApplicationJob
  queue_as :default

  def perform(lesson_id)
    lesson = Lesson.find(lesson_id)
    Lessons::TextProcessor.new(lesson).call
    lesson.reload

    Lessons::AiSummary::TextSummarizer.new(lesson).call
  end
end
