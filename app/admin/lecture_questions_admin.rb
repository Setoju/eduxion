Trestle.resource(:lecture_questions) do
  menu do
    group :ai_content do
      item :lecture_questions, icon: "fas fa-robot", priority: 1, hide: true
    end
  end

  search do |query|
    if query
      LectureQuestion.where("question_text ILIKE :q OR answer_text ILIKE :q", q: "%#{query}%")
    else
      LectureQuestion.all
    end
  end

  table do
    column :question_text, truncate: 80, link: true
    column :answer_text, truncate: 80
    column :lesson, ->(lq) { lq.lesson.title }, link: false
    column :position, align: :center
    column :created_at, align: :center
    actions
  end

  form do |lq|
    select :lesson_id, Lesson.includes(topic: :course).map { |l|
      ["#{l.topic.course.title} > #{l.topic.title} > #{l.title}", l.id]
    }
    text_area :question_text, rows: 4
    text_area :answer_text, rows: 4
    number_field :position
  end

  params do |params|
    params.require(:lecture_question).permit(:lesson_id, :question_text, :answer_text, :position)
  end
end
