Trestle.resource(:bookmarks) do
  menu do
    group :learning do
      item :bookmarks, icon: "fas fa-bookmark", priority: 5
    end
  end

  table do
    column :user, ->(b) { "#{b.user.first_name} #{b.user.last_name}" }
    column :course, ->(b) { b.course.title }, link: false
    column :created_at, align: :center
    actions
  end

  form do |bookmark|
    select :user_id, User.all.map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
    select :course_id, Course.all.map { |c| [c.title, c.id] }
  end

  params do |params|
    params.require(:bookmark).permit(:user_id, :course_id)
  end
end
