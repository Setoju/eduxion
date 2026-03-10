Trestle.resource(:users, model: User, scope: Auth) do
  menu do
    group :configuration, priority: :last do
      item :users, icon: "fas fa-users"
    end
  end

  search do |query|
    if query
      User.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: "%#{query}%")
    else
      User.all
    end
  end

  scope :all, default: true
  scope :teachers, -> { User.where(role: "teacher") }
  scope :students, -> { User.where(role: "student") }

  table do
    column :avatar, header: false do |user|
      avatar_for(user)
    end
    column :first_name
    column :last_name
    column :email, link: true
    column :role do |user|
      status_tag(user.role, user.teacher? ? :success : :default)
    end
    column :admin do |user|
      status_tag(user.admin? ? "Yes" : "No", user.admin? ? :success : :default)
    end
    column :created_at, align: :center
    actions do |a|
      a.delete unless a.instance == current_user
    end
  end

  form do |user|
    tab :account do
      row do
        col(sm: 6) { text_field :first_name }
        col(sm: 6) { text_field :last_name }
      end

      text_field :email
      select :role, %w[student teacher]
      check_box :admin

      row do
        col(sm: 6) { password_field :password }
        col(sm: 6) { password_field :password_confirmation }
      end
    end

    tab :courses, badge: user.courses.count do
      table user.courses, admin: :courses do
        column :title, link: true
        column :public
        column :is_archived
        column :created_at
      end
    end

    tab :enrollments, badge: user.enrollments.count do
      table user.enrollments, admin: :enrollments do
        column :course, ->(e) { e.course.title }, link: true
        column :enrolled_at
      end
    end
  end

  # Ignore the password parameters if they are blank
  update_instance do |instance, attrs|
    if attrs[:password].blank?
      attrs.delete(:password)
      attrs.delete(:password_confirmation) if attrs[:password_confirmation].blank?
    end

    instance.assign_attributes(attrs)
  end

  params do |params|
    params.require(:user).permit(
      :first_name, :last_name, :email, :role, :admin,
      :password, :password_confirmation
    )
  end

  # Log the current user back in if their password was changed
  after_action on: :update do
    if instance == current_user && instance.encrypted_password_previously_changed?
      login!(instance)
    end
  end if Devise.sign_in_after_reset_password
end
