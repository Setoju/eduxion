module Lessons
  class Chunker
    MAX_CHUNK_SIZE = 4000

    def initialize(sentences)
      @sentences = sentences
    end

    def call
      return [] if @sentences.empty?

      chunk_sentences
    end

      private

        def chunk_sentences
          chunks = []
          current_chunk = []
          current_length = 0

          @sentences.each do |sentence|
            sentence_length = sentence.length

            # If adding this sentence would exceed the limit and we have content in current chunk
            if current_length + sentence_length > MAX_CHUNK_SIZE && !current_chunk.empty?
              # Save current chunk and start a new one
              chunks << current_chunk.join(" ")
              current_chunk = []
              current_length = 0
            end

            current_chunk << sentence
            current_length += sentence_length + 1 # +1 for space between sentences
          end

          # Add the final chunk if it has content
          chunks << current_chunk.join(" ") if !current_chunk.empty?

          chunks
        end
  end
end
