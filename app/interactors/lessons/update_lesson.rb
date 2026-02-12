module Lessons
  class UpdateLesson
    include Interactor

    before :validate_context!

    def call
      update_lesson(context.id, context.params)

      if @lesson.persisted?
        check_content_checksum
        message = "Teacher #{@lesson.topic.course.instructor.first_name} updated lesson: #{@lesson.title}"
        url = Rails.application.routes.url_helpers.course_topic_lesson_path(@lesson.topic.course, @lesson.topic, @lesson)
        @lesson.topic.course.students.each do |student|
          ApplicationNotifier.with(
              message: message,
              url: url,
              type: "Lesson"
          ).deliver_later(student)
        end

        check_lesson_open_status
        context.lesson = @lesson
      else
        context.fail!(error: @lesson.errors.full_messages.to_sentence)
      end
    end

    private

      def validate_context!
        if context.id.nil? || context.params.nil? || context.course.nil? || context.topic.nil?
          context.fail!(error: "Invalid context")
        end
      end

      def check_lesson_open_status
        @lesson.update!(is_open: true) if @lesson.ends_at.present? && @lesson.ends_at > Time.current
      end

      def update_lesson(id, params)
        @lesson = Lesson.find(id)
        @lesson.update(params)
      end

      def check_content_checksum
        return if @lesson.content_type != "text"
        return if @lesson.content.blank?

        new_checksum = Digest::SHA256.hexdigest(@lesson.content.strip)
        if @lesson.content_checksum != new_checksum
          @lesson.update!(content_checksum: new_checksum)
          @lesson.lesson_ai_summaries.destroy_all
          @lesson.lecture_questions.destroy_all

          @lesson.update!(question_generation_status: "pending")
          LectureQuestionsGeneratorJob.perform_later(@lesson.id)
        end
      end
  end
end
