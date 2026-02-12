module Lessons
  module AiSummary
    class TextSummarizer
      def initialize(lesson)
        @lesson = lesson
      end

      def call
        return unless @lesson.content_type == "text" && @lesson.content.present?

        update_status("generating")

        chunks = @lesson.lesson_ai_summaries
        return if chunks.empty?

        summaries = ChunkSummarizer.new.call(chunks)
        combined_summary = summaries.join("\n\n")

        questions = QuestionGenerator.new.call(combined_summary, num_questions: num_questions)
        save_questions(questions)

        update_status("generated")
        broadcast_questions_update
      rescue => e
        update_status("failed")
        broadcast_questions_update
        raise
      end

      private

      def num_questions
        case @lesson.lesson_ai_summaries.count
        when 1..3 then 3
        when 4..10 then 5
        else 10
        end
      end

      def save_questions(questions)
        questions.each_with_index do |question, index|
          @lesson.lecture_questions.create!(
            question_text: question,
            answer_text: "",
            position: index
          )
        end
      end

      def update_status(status)
        @lesson.update!(question_generation_status: status)
      end

      def broadcast_questions_update
        Turbo::StreamsChannel.broadcast_replace_to(
          "lesson_#{@lesson.id}_questions",
          target: "lesson_questions",
          partial: "lessons/questions_section",
          locals: { lesson: @lesson.reload }
        )
      end
    end
  end
end
