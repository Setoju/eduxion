Trestle.resource(:invitations) do
  menu do
    group :communication do
      item :invitations, icon: "fas fa-envelope", priority: 1
    end
  end

  search do |query|
    if query
      Invitation.where("email ILIKE ?", "%#{query}%")
    else
      Invitation.all
    end
  end

  scope :all, default: true
  scope :pending, -> { Invitation.where(status: "pending") }
  scope :accepted, -> { Invitation.where(status: "accepted") }

  table do
    column :email, link: true
    column :course, ->(i) { i.course.title }, link: false
    column :invited_by, ->(i) { i.invited_by&.email }
    column :status do |inv|
      status_tag(inv.status, { "pending" => :warning, "accepted" => :success }[inv.status] || :default)
    end
    column :created_at, align: :center
    actions
  end

  form do |invitation|
    text_field :email
    select :course_id, Course.all.map { |c| [c.title, c.id] }
    select :invited_by_id, User.where(role: "teacher").map { |u| ["#{u.first_name} #{u.last_name} (#{u.email})", u.id] }
    select :status, %w[pending accepted declined expired]
  end

  params do |params|
    params.require(:invitation).permit(:email, :course_id, :invited_by_id, :status)
  end
end
