require "whatlanguage"

module Lessons
  class SentenceSplitter
    def initialize(text)
      @text = text
      @language = detect_language
    end

    def call
      PragmaticSegmenter::Segmenter.new(text: @text, language: @language).segment
    end

    private

      def detect_language
        wl = WhatLanguage.new(:all)
        detected = wl.language_iso(@text)

        language_mapping = {
          "english" => :en,
          "spanish" => :es,
          "french" => :fr,
          "german" => :de,
          "italian" => :it,
          "portuguese" => :pt,
          "russian" => :ru,
          "arabic" => :ar,
          "japanese" => :ja,
          "chinese" => :zh
        }

        language_mapping[detected] || :en
      end
  end
end
