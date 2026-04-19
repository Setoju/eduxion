# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   [ "Action", "Comedy", "Drama", "Horror" ].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.create!(
    first_name: "John",
    last_name: "Doe",
    email: "john@example.com",
    password: "password"
)

20.times do |i|
  Course.create!(
      title: "Course #{i}",
      description: "Description for course #{i}",
      instructor_id: User.last.id,
  )
end

# =============================================================================
# LAG INDICATOR TEST DATA
#
# One course with 4 lessons and 4 students at different completion levels:
#   alice@lagtest.com   — 4/4 complete (100%) → NOT lagging  (gap ≈ -33%)
#   barely@lagtest.com  — 2/4 complete  (50%) → NOT lagging  (gap ≈  17%)
#   dave@lagtest.com    — 1/4 complete  (25%) → LAGGING       (gap ≈  42%)
#   charlie@lagtest.com — 0/4 complete   (0%) → LAGGING       (gap ≈  67%)
#
# Course is backdated so ~67% of its duration has elapsed (60/90 days).
# Expected completion ≈ 67%, lag_threshold = 20.
# Login: any of the above emails, password "password".
# =============================================================================

puts "\nSeeding lag indicator test data..."

lag_teacher = User.find_or_create_by!(email: "lag.teacher@example.com") do |u|
  u.first_name = "Lag"
  u.last_name  = "Teacher"
  u.password   = "password"
  u.role       = "teacher"
end

lag_course = Course.find_or_create_by!(title: "Lag Test Course") do |c|
  c.description   = "Course for testing the lagging student indicator feature in the show page."
  c.instructor    = lag_teacher
  c.public        = false
  c.ends_at       = 30.days.from_now
  c.lag_threshold = 20
end

# Backdate so 60 of 90 days have elapsed → expected completion ≈ 67%
lag_course.update_columns(created_at: 60.days.ago, updated_at: 60.days.ago)

topic = Topic.find_or_create_by!(title: "Lag Test Topic", course: lag_course) do |t|
  t.position = 1
end

lessons = (1..4).map do |i|
  Lesson.find_or_create_by!(title: "Lag Lesson #{i}", topic: topic) do |l|
    l.content_type             = "text"
    l.content                  = "This is the full content for lag test lesson number #{i}. Read carefully."
    l.position                 = i
    l.question_generation_status = "disabled"
    l.content_checksum         = SecureRandom.hex(10)
  end
end

[
  { first_name: "Alice",   last_name: "Ahead",    email: "alice@lagtest.com",   complete: 4 },
  { first_name: "Barely",  last_name: "Behind",   email: "barely@lagtest.com",  complete: 2 },
  { first_name: "Dave",    last_name: "Delayed",  email: "dave@lagtest.com",    complete: 1 },
  { first_name: "Charlie", last_name: "Clueless", email: "charlie@lagtest.com", complete: 0 },
].each do |attrs|
  complete_count = attrs.delete(:complete)

  student = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.first_name = attrs[:first_name]
    u.last_name  = attrs[:last_name]
    u.password   = "password"
    u.role       = "student"
  end

  Enrollment.find_or_create_by!(user: student, course: lag_course) do |e|
    e.enrolled_at = 59.days.ago
  end

  lessons.first(complete_count).each do |lesson|
    Response.find_or_create_by!(responseable: lesson, user: student) do |r|
      r.content = "I have read and understood this lesson."
    end
  end
end

puts "  Course : '#{lag_course.title}' (id=#{lag_course.id})"
puts "  URL    : /courses/#{lag_course.id}"
puts "  Teacher: lag.teacher@example.com / password"
puts "  Students (all password: 'password'):"
puts "    alice@lagtest.com   — 4/4 lessons  → NOT lagging"
puts "    barely@lagtest.com  — 2/4 lessons  → NOT lagging"
puts "    dave@lagtest.com    — 1/4 lessons  → LAGGING"
puts "    charlie@lagtest.com — 0/4 lessons  → LAGGING"
