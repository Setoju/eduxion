Trestle.resource(:marks) do
  menu do
    group :assessments do
      item :marks, icon: "fas fa-star", priority: 4
    end
  end

  table do
    column :user, ->(m) { "#{m.user.first_name} #{m.user.last_name}" }
    column :lesson, ->(m) { m.lesson.title }, link: false
    column :value, align: :center, header: "Score"
    column :comment, truncate: 60
    column :response, ->(m) { m.response_id.present? ? "Yes" : "No" }, align: :center
    column :created_at, align: :center
    actions
  end

  form do |mark|
    select :user_id, User.all.map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
    select :lesson_id, Lesson.includes(topic: :course).map { |l|
      ["#{l.topic.course.title} > #{l.topic.title} > #{l.title}", l.id]
    }
    number_field :value, min: 0, max: 100
    text_field :comment
    select :response_id, Response.all.map { |r| ["Response ##{r.id} by #{r.user.first_name}", r.id] }, include_blank: true
  end

  params do |params|
    params.require(:mark).permit(:user_id, :lesson_id, :value, :comment, :response_id)
  end
end
