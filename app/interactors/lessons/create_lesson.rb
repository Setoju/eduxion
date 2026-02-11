module Lessons
  class CreateLesson
    include Interactor

    before :validate_context!

    def call
      create_lesson(context.params)

      if @lesson.save
        message = "Teacher #{@lesson.topic.course.instructor.first_name} edited the lesson: #{@lesson.title}"
        url = Rails.application.routes.url_helpers.course_topic_lesson_path(@lesson.topic.course, @lesson.topic, @lesson)
        @lesson.topic.course.students.each do |student|
          ApplicationNotifier.with(
              message: message,
              url: url,
              type: "Lesson"
          ).deliver_later(student)
        end

        context.lesson = @lesson
      else
        context.fail!(error: @lesson.errors.full_messages.to_sentence)
      end
    end

    private

    def validate_context!
      if context.params.nil? || context.course.nil? || context.topic.nil?
        context.fail!(error: "Invalid context")
      end
    end

    def create_lesson(params)
      @lesson = Lesson.new(params)
      @lesson.topic = context.topic
          
      if @lesson.content_type == "text" && @lesson.content.present?
        @lesson.content_checksum = Digest::SHA256.hexdigest(@lesson.content.strip)
      end
    end
  end
end
