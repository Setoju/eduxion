module Lessons
  module AiSummary
    class GeminiClient
      BASE_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemma-3-1b-it:generateContent"

      def initialize
        @api_key = ENV.fetch("GOOGLE_AI_API_KEY")
      end

      def generate(prompt, max_tokens: 1000, temperature: 0.3)
        uri = URI("#{BASE_URL}?key=#{@api_key}")

        payload = {
          contents: [{
            parts: [{ text: prompt }]
          }]
        }

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(uri)
        request["Content-Type"] = "application/json"
        request.body = payload.to_json

        response = http.request(request)

        raise "API request failed: #{response.code}" unless response.code == "200"

        body = JSON.parse(response.body)
        body.dig("candidates", 0, "content", "parts", 0, "text")&.strip
      end
    end
  end
end
