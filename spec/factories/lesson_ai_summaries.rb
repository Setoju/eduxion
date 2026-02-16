FactoryBot.define do
  factory :lesson_ai_summary do
    association :lesson
    summary_text { Faker::Lorem.paragraph }
    chunk_index { Faker::Number.non_zero_digit }
  end
end
