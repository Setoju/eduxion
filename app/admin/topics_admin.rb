Trestle.resource(:topics) do
  menu do
    group :learning do
      item :topics, icon: "fas fa-list", priority: 2
    end
  end

  search do |query|
    if query
      Topic.where("title ILIKE ?", "%#{query}%")
    else
      Topic.all
    end
  end

  table do
    column :title, link: true
    column :course, ->(t) { t.course.title }, link: false
    column :position, align: :center
    column :lessons, ->(t) { t.lessons.count }, align: :center
    column :created_at, align: :center
    actions
  end

  form do |topic|
    tab :details do
      text_field :title
      select :course_id, Course.all.map { |c| [c.title, c.id] }
      number_field :position
    end

    tab :lessons, badge: topic.lessons.count do
      table topic.lessons.ordered, admin: :lessons do
        column :title, link: true
        column :content_type do |l|
          status_tag(l.content_type, { "text" => :default, "video" => :info, "quiz" => :success }[l.content_type] || :default)
        end
        column :position, align: :center
        column :is_open do |l|
          status_tag(l.is_open? ? "Open" : "Closed", l.is_open? ? :success : :danger)
        end
      end
    end
  end

  params do |params|
    params.require(:topic).permit(:title, :course_id, :position)
  end
end
