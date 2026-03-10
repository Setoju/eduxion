Trestle.resource(:responses) do
  menu do
    group :assessments do
      item :responses, icon: "fas fa-reply", priority: 3, hide: true
    end
  end

  scope :all, default: true

  table do
    column :user, ->(r) { "#{r.user.first_name} #{r.user.last_name}" }
    column :content, truncate: 80
    column :responseable_type
    column :responseable_id
    column :attachment do |r|
      r.attachment.present? ? status_tag("Attached", :info) : nil
    end
    column :created_at, align: :center
    actions
  end

  form do |response|
    select :user_id, User.all.map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
    text_area :content, rows: 5
    static_field :responseable_type
    static_field :responseable_id
    static_field :attachment do
      if response.attachment.present?
        link_to response.attachment.url, response.attachment.url, target: "_blank"
      else
        "No attachment"
      end
    end
    static_field :created_at
  end

  params do |params|
    params.require(:response).permit(:user_id, :content)
  end
end
