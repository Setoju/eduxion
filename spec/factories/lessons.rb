FactoryBot.define do
  factory :lesson do
    title { Faker::Lorem.sentence.truncate(50) }
    content { Faker::Lorem.sentence }
    content_checksum { SecureRandom.hex(10) }
    topic { association(:topic) }
    position { 1 }

    trait :with_video do
      content_type { "video" }
      video_url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    end

    trait :with_text do
      content_type { "text" }
      content { Faker::Lorem.sentence }
    end

    trait :with_quiz do
      content_type { "quiz" }
      content { Faker::Lorem.sentence }
    end
  end
end
