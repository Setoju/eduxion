module Lessons
  module AiSummary
    class ChunkSummarizer
      def initialize(client: GeminiClient.new)
        @client = client
      end

      def call(chunks)
        chunks.each_with_index.filter_map do |chunk, index|
          sleep(0.5) if index > 0
          summarize(chunk.summary_text)
        end
      end

      private

      def summarize(text)
        @client.generate(prompt_for(text), max_tokens: 1000, temperature: 0.3)
      rescue => e
        nil
      end

      def prompt_for(chunk_text)
        <<~PROMPT
          Please provide a concise summary of the following educational text chunk.
          Focus on the key concepts, main points, and important details that a student should understand.
          Keep the summary informative but brief (2-3 sentences).
          The summary should be in the same language as the original text.

          Text to summarize:
          #{chunk_text}
        PROMPT
      end
    end
  end
end