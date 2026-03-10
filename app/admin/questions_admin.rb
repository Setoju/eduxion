Trestle.resource(:questions) do
  menu do
    group :assessments do
      item :questions, icon: "fas fa-question-circle", priority: 1
    end
  end

  search do |query|
    if query
      Question.where("title ILIKE :q OR content ILIKE :q", q: "%#{query}%")
    else
      Question.all
    end
  end

  table do
    column :title, link: true
    column :lesson, ->(q) { q.lesson.title }, link: false
    column :options, ->(q) { q.options.count }, align: :center
    column :correct_answer, ->(q) { q.correct_option&.title }
    column :created_at, align: :center
    actions
  end

  form do |question|
    tab :details do
      text_field :title
      text_area :content, rows: 4
      select :lesson_id, Lesson.where(content_type: "quiz").includes(topic: :course).map { |l|
        ["#{l.topic.course.title} > #{l.topic.title} > #{l.title}", l.id]
      }
    end

    tab :options, badge: question.options.count do
      table question.options, admin: :options do
        column :title, link: true
        column :is_correct do |opt|
          status_tag(opt.is_correct? ? "Correct" : "Incorrect", opt.is_correct? ? :success : :default)
        end
      end
    end
  end

  params do |params|
    params.require(:question).permit(:title, :content, :lesson_id)
  end
end
