Trestle.resource(:courses) do
  menu do
    group :learning do
      item :courses, icon: "fas fa-graduation-cap", priority: 1
    end
  end

  search do |query|
    if query
      Course.where("title ILIKE :q OR description ILIKE :q", q: "%#{query}%")
    else
      Course.all
    end
  end

  scope :all, default: true
  scope :public_courses, -> { Course.where(public: true) }, label: "Public"
  scope :private_courses, -> { Course.where(public: false) }, label: "Private"
  scope :archived, -> { Course.where(is_archived: true) }
  scope :active, -> { Course.where(is_archived: false) }

  table do
    column :title, link: true
    column :instructor, ->(course) { course.instructor&.email }
    column :public do |course|
      status_tag(course.public? ? "Public" : "Private", course.public? ? :success : :warning)
    end
    column :is_archived do |course|
      status_tag(course.is_archived? ? "Archived" : "Active", course.is_archived? ? :danger : :success)
    end
    column :students, ->(course) { course.students.count }, align: :center
    column :topics, ->(course) { course.topics.count }, align: :center
    column :ends_at, align: :center
    column :created_at, align: :center
    actions
  end

  form do |course|
    tab :details do
      text_field :title
      text_area :description, rows: 5
      select :instructor_id, User.where(role: "teacher").map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
      check_box :public
      check_box :is_archived
      datetime_field :ends_at
    end

    tab :topics, badge: course.topics.count do
      table course.topics.ordered, admin: :topics do
        column :title, link: true
        column :position, align: :center
        column :lessons, ->(t) { t.lessons.count }, align: :center
      end
    end

    tab :enrollments, badge: course.enrollments.count do
      table course.enrollments, admin: :enrollments do
        column :user, ->(e) { "#{e.user.first_name} #{e.user.last_name}" }, link: false
        column :email, ->(e) { e.user.email }
        column :enrolled_at
      end
    end

    tab :invitations, badge: course.invitations.count do
      table course.invitations, admin: :invitations do
        column :email
        column :status do |inv|
          status_tag(inv.status, inv.status == "accepted" ? :success : :warning)
        end
        column :created_at
      end
    end
  end

  params do |params|
    params.require(:course).permit(
      :title, :description, :instructor_id, :public, :is_archived, :ends_at
    )
  end
end
