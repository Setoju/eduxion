LagStatus = Data.define(:student_id, :student_name, :actual_pct, :expected_pct, :gap, :lagging)

class LagCalculatorService
  def initialize(course)
    @course = course
  end

  # Returns an Array of LagStatus value objects, one per enrolled student.
  def call
    progress_rows = CourseProgressQuery.new(@course.id).call
    return [] if progress_rows.empty?

    expected = expected_pct(progress_rows)

    # Bulk-load student names to avoid N+1 queries
    student_ids = progress_rows.map { |r| r["student_id"] }
    names = User.where(id: student_ids).pluck(:id, :first_name).to_h

    progress_rows.map do |row|
      sid    = row["student_id"]
      actual = row["completion_percentage"].to_f
      exp    = expected
      gap    = (exp - actual).round(2)

      LagStatus.new(
        student_id:   sid,
        student_name: names[sid] || "Unknown",
        actual_pct:   actual,
        expected_pct: exp,
        gap:          gap,
        lagging:      gap > @course.lag_threshold
      )
    end
  end

  private

    # Returns a Float representing the expected completion % for all students.
    # When the course has an end date, this is time-based (same value for everyone).
    # When there is no end date, it equals the class average actual completion.
    def expected_pct(progress_rows)
      if @course.ends_at.present?
        total_days = (@course.ends_at - @course.created_at).to_f / 1.day
        elapsed    = (Time.current - @course.created_at).to_f / 1.day
        [[elapsed / total_days * 100.0, 0.0].max, 100.0].min
      else
        values = progress_rows.map { |r| r["completion_percentage"].to_f }
        values.sum / values.size
      end
    end
end
