module Lessons
  class UpdateSummaryQuestions
    include Interactor
    
    def call
      @lesson = context.lesson || Lesson.find_by(id: context.id)
      return unless @lesson
      return if @lesson.content_type != "text"

      if @lesson.generate_summary_questions
        process_generation
      else
        process_disabling
      end
    end

    private 

    def process_generation
      if lesson_content_changed? || !questions_exist?
        generate_questions
      else
        @lesson.update!(question_generation_status: "generated")
      end
    end

    def process_disabling
      if lesson_content_changed?
        remove_questions
      else
        @lesson.update!(question_generation_status: "disabled")
      end
    end

    def questions_exist?
      @lesson.lecture_questions.any? || @lesson.lesson_ai_summaries.any?
    end

    def generate_questions
      return if @lesson.content.blank?

      @lesson.lesson_ai_summaries.destroy_all
      @lesson.lecture_questions.destroy_all

      @lesson.update!(
        content_checksum: Digest::SHA256.hexdigest(@lesson.content.strip),
        question_generation_status: "pending"
      )

      LectureQuestionsGeneratorJob.perform_later(@lesson.id)
    end

    def remove_questions
      return unless @lesson.lecture_questions.any? || @lesson.lesson_ai_summaries.any?

      @lesson.lesson_ai_summaries.destroy_all
      @lesson.lecture_questions.destroy_all
      @lesson.update!(question_generation_status: "disabled")
    end

    def lesson_content_changed?
      return false if @lesson.content.blank?

      new_checksum = Digest::SHA256.hexdigest(@lesson.content.strip)
      @lesson.content_checksum != new_checksum
    end
  end
end