Trestle.admin(:dashboard) do
  menu do
    item :dashboard, icon: "fas fa-tachometer-alt", priority: :first
  end

  controller do
    def index
      @users_count = User.count
      @courses_count = Course.count
      @enrollments_count = Enrollment.count
      @lessons_count = Lesson.count
      @recent_courses = Course.order(created_at: :desc).limit(5)
      @recent_users = User.order(created_at: :desc).limit(5)
    end
  end
end
