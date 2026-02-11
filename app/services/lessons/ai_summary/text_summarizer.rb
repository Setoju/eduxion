module Lessons
  module AiSummary
    class TextSummarizer
      def initialize(lesson, num_questions: 5)
        @lesson = lesson
        @num_questions = num_questions
        # gemini-2.5-flash-lite for multilingual support gemma-3-1b-it
        @base_url = "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-1b-it:generateContent"
      end

      def call
        return unless @lesson.content_type == "text" && @lesson.content.present?

        @lesson.update!(question_generation_status: "generating")

        chunks = @lesson.lesson_ai_summaries
        Rails.logger.info "TextSummarizer: Found #{chunks.count} chunks for lesson #{@lesson.id}"

        return if chunks.empty?

        chunk_summaries = summarize_chunks(chunks)
        Rails.logger.info "TextSummarizer: Generated #{chunk_summaries.count} summaries"

        combined_summary = chunk_summaries.join("\n\n")

        summary_questions = generate_summary_questions(combined_summary)
        Rails.logger.info "TextSummarizer: Generated #{summary_questions.count} questions"

        summary_questions.each_with_index do |question, index|
          @lesson.lecture_questions.create!(
              question_text: question,
              answer_text: "",
              position: index
          )
        end
      ensure
        @lesson.update!(question_generation_status: "generated")
      end

      private

      def summarize_chunks(chunks)
        summaries = []

        chunks.each_with_index do |chunk, index|
          # Add small delay to avoid rate limiting
          sleep(0.5) if index > 0

          summary = summarize_single_chunk(chunk.summary_text)
          summaries << summary if summary.present?
        end

        summaries.each_with_index do |summary, index|
          Rails.logger.info "Summary for chunk #{index}: #{summary}"
        end

        summaries
      end

      def summarize_single_chunk(chunk_text)
        prompt = build_chunk_summary_prompt(chunk_text)

        response = make_api_request(prompt, max_tokens: 1000, temperature: 0.3)

        response.dig("candidates", 0, "content", "parts", 0, "text")&.strip
      rescue => e
        Rails.logger.error "Google AI API error for chunk summarization: #{e.message}"
        nil
      end

      def generate_summary_questions(combined_summary)
        prompt = build_questions_prompt(combined_summary)

        response = make_api_request(prompt, max_tokens: 2000, temperature: 0.4)

        Rails.logger.info "Google AI API response for question generation: #{response}"

        questions = response.dig("candidates", 0, "content", "parts", 0, "text")&.strip

        parse_questions(questions)
      rescue => e
        Rails.logger.error "Google AI API error for question generation: #{e.message}"
        []
      end

      def make_api_request(prompt, max_tokens: 1000, temperature: 0.3)
        require "net/http"
        require "json"

        uri = URI("#{@base_url}?key=#{api_key}")

        payload = {
          contents: [{
            parts: [{
              text: prompt
            }]
          }]
        }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = payload.to_json

        response = http.request(request)

        if response.code == "200"
          JSON.parse(response.body)
        else
          Rails.logger.error "Google AI API error: #{response.code} - #{response.body}"
          raise "API request failed: #{response.code}"
        end
      end

      def build_chunk_summary_prompt(chunk_text)
        <<~PROMPT
          Please provide a concise summary of the following educational text chunk.#{' '}
          Focus on the key concepts, main points, and important details that a student should understand.
          Keep the summary informative but brief (2-3 sentences).
          The summary should be in the same language as the original text.

          Text to summarize:
          #{chunk_text}
        PROMPT
      end

      def build_questions_prompt(combined_summary)
        <<~PROMPT
          Based on the following lesson summary, create exactly #{@num_questions} thoughtful questions that test student comprehension and understanding of the material.

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

      def parse_questions(questions_text)
        return [] if questions_text.blank?

        questions = []

        questions = questions_text.split(/\n+/)
                                 .map(&:strip)
                                 .select { |line| line.match?(/^\d+\./) }
                                 .map { |line| line.gsub(/^\d+\.\s*/, "") }
                                 .reject(&:blank?)

        questions
      end

      def api_key
        ENV.fetch("GOOGLE_AI_API_KEY")
      end
    end
  end
end
