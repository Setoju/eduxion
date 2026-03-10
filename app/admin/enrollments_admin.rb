Trestle.resource(:enrollments) do
  menu do
    group :learning do
      item :enrollments, icon: "fas fa-user-plus", priority: 4
    end
  end

  scope :all, default: true

  table do
    column :user, ->(e) { "#{e.user.first_name} #{e.user.last_name}" }
    column :email, ->(e) { e.user.email }
    column :course, ->(e) { e.course.title }, link: false
    column :enrolled_at, align: :center
    column :created_at, align: :center
    actions
  end

  form do |enrollment|
    select :user_id, User.all.map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
    select :course_id, Course.all.map { |c| [c.title, c.id] }
    datetime_field :enrolled_at
  end

  params do |params|
    params.require(:enrollment).permit(:user_id, :course_id, :enrolled_at)
  end
end
