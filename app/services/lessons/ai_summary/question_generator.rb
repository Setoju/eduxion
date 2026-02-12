module Lessons
  module AiSummary
    class QuestionGenerator
      def initialize(client: GeminiClient.new)
        @client = client
      end

      def call(summary_text, num_questions:)
        prompt = prompt_for(summary_text, num_questions)
        response = @client.generate(prompt, max_tokens: 2000, temperature: 0.4)
        parse(response)
      rescue => e
        []
      end

      private

      def parse(text)
        return [] if text.blank?

        text.split(/\n+/)
            .map(&:strip)
            .select { |line| line.match?(/^\d+\./) }
            .map { |line| line.gsub(/^\d+\.\s*/, "") }
            .reject(&:blank?)
      end

      def prompt_for(combined_summary, num_questions)
        <<~PROMPT
          Based on the following lesson summary, create exactly #{num_questions} thoughtful questions that test student comprehension and understanding of the material.

          Requirements:
          - Questions should cover different aspects of the material
          - Mix of factual recall and conceptual understanding questions
          - Each question should be clear and specific
          - Format each question on a new line starting with a number (1., 2., etc.)
          - Do not include answers, only questions
          - Avoid yes/no questions; focus on open-ended questions that require explanation
          - Ensure questions are relevant to the key points in the summary
          - Do not refer to the text as a "summary" in the questions; treat it as the lesson content
          - Questions should be in the same language as the summary

          Lesson Summary:
          #{combined_summary}
        PROMPT
      end
    end
  end
end
