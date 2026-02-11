module Lessons
  class TextProcessor
    def initialize(lesson)
      @lesson = lesson
    end

    def call
      return unless @lesson.content_type == "text" && @lesson.content.present?

      sentences = Lessons::SentenceSplitter.new(@lesson.content).call
      chunks = Lessons::Chunker.new(sentences).call

      chunks.each_with_index do |chunk, index|
        @lesson.lesson_ai_summaries.create!(
            summary_text: chunk,
            chunk_index: index
        )
      end
    end
  end
end
