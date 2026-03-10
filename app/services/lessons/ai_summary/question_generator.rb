module Lessons
  module AiSummary
    class QuestionGenerator
      def initialize(client: GeminiClient.new)
        @client = client
      end

      def call(summary_text, num_questions:)
        prompt = prompt_for(summary_text, num_questions)
        response = @client.generate(prompt, max_tokens: 2000, temperature: 0.4)
        questions = parse(response)
        Rails.logger.info("[QuestionGenerator] Generated #{questions.size} questions from response (#{response&.length || 0} chars)")
        Rails.logger.debug("[QuestionGenerator] Raw response: #{response}") if questions.empty?
        questions
      rescue => e
        Rails.logger.error("[QuestionGenerator] Error generating questions: #{e.message}")
        []
      end

      private

      def parse(text)
        return [] if text.blank?

        text.split(/\n+/)
            .map(&:strip)
            .map { |line| line.gsub(/^\*{0,2}\s*/, "") }
            .select { |line| line.match?(/^\d+[.):]/) }
            .map { |line| line.gsub(/^\d+[.):]+\s*/, "") }
            .map { |line| line.gsub(/\*{2}/, "") }
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

          --- BEGIN LESSON CONTENT ---
            Lesson Summary:
            #{combined_summary}
          --- END LESSON CONTENT ---
        PROMPT
      end
    end
  end
end
