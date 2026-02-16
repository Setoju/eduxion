FactoryBot.define do
  factory :lecture_question do
    association :lesson
    question_text { Faker::Lorem.sentence }
    position { Faker::Number.non_zero_digit }
  end
end
