class CourseProgressQuery
  def initialize(course_id)
    @course_id = course_id
  end

  def call
    ActiveRecord::Base.connection.exec_query(
      ActiveRecord::Base.send(:sanitize_sql_array, [ SQL, @course_id ])
    )
  end

  private

    SQL = <<~SQL
      SELECT
        e.user_id AS student_id,
        COUNT(DISTINCT l.id) AS total_lessons,
        COUNT(DISTINCT CASE WHEN r.id IS NOT NULL OR qr.id IS NOT NULL THEN l.id END)
          AS lessons_completed,
        CASE
          WHEN COUNT(DISTINCT l.id) = 0 THEN 0.0
          ELSE ROUND(
            100.0 * COUNT(DISTINCT CASE WHEN r.id IS NOT NULL OR qr.id IS NOT NULL THEN l.id END)
                    / COUNT(DISTINCT l.id),
            2
          )
        END AS completion_percentage
      FROM courses c
      LEFT JOIN enrollments e ON e.course_id = c.id
      LEFT JOIN topics t ON t.course_id = c.id
      LEFT JOIN lessons l ON l.topic_id = t.id
      LEFT JOIN questions q ON q.lesson_id = l.id
      LEFT JOIN responses r
        ON r.responseable_type = 'Lesson'
        AND r.responseable_id = l.id
        AND r.user_id = e.user_id
      LEFT JOIN responses qr
        ON qr.responseable_type = 'Question'
        AND qr.responseable_id = q.id
        AND qr.user_id = e.user_id
      WHERE c.id = ?
      GROUP BY e.user_id
    SQL
end
