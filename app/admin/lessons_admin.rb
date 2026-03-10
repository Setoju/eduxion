Trestle.resource(:lessons) do
  menu do
    group :learning do
      item :lessons, icon: "fas fa-book-open", priority: 3
    end
  end

  search do |query|
    if query
      Lesson.where("title ILIKE :q OR content ILIKE :q", q: "%#{query}%")
    else
      Lesson.all
    end
  end

  scope :all, default: true
  scope :text, -> { Lesson.where(content_type: "text") }
  scope :video, -> { Lesson.where(content_type: "video") }
  scope :quiz, -> { Lesson.where(content_type: "quiz") }
  scope :open, -> { Lesson.where(is_open: true) }
  scope :closed, -> { Lesson.where(is_open: false) }

  table do
    column :title, link: true
    column :topic, ->(l) { l.topic.title }, link: false
    column :course, ->(l) { l.topic.course.title }, link: false
    column :content_type do |l|
      status_tag(l.content_type, { "text" => :default, "video" => :info, "quiz" => :success }[l.content_type] || :default)
    end
    column :position, align: :center
    column :is_open do |l|
      status_tag(l.is_open? ? "Open" : "Closed", l.is_open? ? :success : :danger)
    end
    column :ends_at, align: :center
    column :created_at, align: :center
    actions
  end

  form do |lesson|
    tab :details do
      text_field :title
      select :topic_id, Topic.includes(:course).map { |t| ["#{t.course.title} > #{t.title}", t.id] }
      select :content_type, Lesson::ALLOWED_CONTENT_TYPES.map { |ct| [ct.capitalize, ct] }
      text_area :content, rows: 10
      text_field :video_url
      number_field :position
      check_box :is_open
      datetime_field :ends_at
    end

    tab :questions, badge: lesson.questions.count do
      table lesson.questions, admin: :questions do
        column :title, link: true
        column :options, ->(q) { q.options.count }, align: :center
      end
    end

    tab :marks, badge: lesson.marks.count do
      table lesson.marks, admin: :marks do
        column :user, ->(m) { "#{m.user.first_name} #{m.user.last_name}" }
        column :value, align: :center
        column :comment
        column :created_at
      end
    end

    tab :ai_content do
      if lesson.persisted?
        row do
          col(sm: 6) do
            h4 = content_tag(:h5, "AI Summaries (#{lesson.lesson_ai_summaries.count})")
            concat(h4)
            lesson.lesson_ai_summaries.each do |summary|
              concat(content_tag(:div, class: "card card-body mb-2") do
                content_tag(:p, summary.summary_text)
              end)
            end
          end
          col(sm: 6) do
            h4 = content_tag(:h5, "Lecture Questions (#{lesson.lecture_questions.count})")
            concat(h4)
            lesson.lecture_questions.each do |lq|
              concat(content_tag(:div, class: "card card-body mb-2") do
                content_tag(:strong, lq.question_text) +
                content_tag(:p, lq.answer_text, class: "text-muted mt-1 mb-0")
              end)
            end
          end
        end
      end
    end
  end

  params do |params|
    params.require(:lesson).permit(
      :title, :topic_id, :content_type, :content, :video_url,
      :position, :is_open, :ends_at
    )
  end
end
