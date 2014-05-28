class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    alias_action :index, :closed, :search, to: :list
    alias_action :new_from_template,       to: :create
    alias_action :confirm_destroy,         to: :destroy

    alias_action :submit_report,
                 :destroy_report,
                 :report_all,
                 :submit_report_all,
      to: :report

    alias_action :add_users,
                 :remove_users,
                 :select_users,
      to: :associate_users

    alias_action :show,
                 :select,
                 :search_participants,
                 :save_state,
                 :clear_state,
                 :add_student_data,
      to: :view

    alias_action :update,
                 :report,
                 :associate_users,
      to: :change

    alias_action :destroy,
                 :add_contributors,
                 :remove_contributors,
                 :confirm_status_change,
                 :change_status,
      to: :control

    if user.has_role?(:admin)
      can :manage, :all
    elsif user.has_role?(:superuser)
      # Students
      can    :manage, Student
      cannot :destroy, Student

      # Groups
      can    :manage, Group

      # Suites
      can :create,            Suite
      can [ :view, :change ], Suite do |suite|
        suite.is_template
      end

      # Evaluations
      can :manage,                         Evaluation
      cannot [ :view, :change, :destroy ], Evaluation do |evaluation|
        evaluation.type_suite?
      end

      # Color tables
      can :create, ColorTable
    end

    can :list,    Suite
    can :view,    Suite do |suite|
      user.has_role?(  :suite_manager,     suite) ||
        user.has_role?(:suite_member,      suite) ||
        user.has_role?(:suite_contributor, suite)
    end
    can :change,  Suite do |suite|
      user.has_role?(  :suite_manager,     suite) ||
        user.has_role?(:suite_contributor, suite)
    end
    can :control, Suite do |suite|
      user.has_role?(:suite_manager, suite)
    end

    readonly_associations = [
      Participant,
      Evaluation,
      Meeting,
      Activity
    ]

    can :view, readonly_associations do |e|
      e.suite && can?(:view, e.suite)
    end
    can [ :view, :create, :change, :destroy ], readonly_associations do |e|
      e.suite && can?(:change, e.suite)
    end
    can :report, Evaluation do |e|
      e.suite && can?(:view, e.suite)
    end
    can :report, Activity do |activity|
      activity.users.include?(user)
    end

    can :search, [ User, Student, Group, Evaluation ]
    can :view,   [ Student, Group ]

    can :list, ColorTable
    can :view, ColorTable do |c|
      c.suite && can?(:view, c.suite) ||
        user.has_role?(:reader, c) ||
        user.has_role?(:editor, c) ||
        user.has_role?(:manager, c)
    end
    can :change, ColorTable do |c|
      c.suite && can?(:change, c.suite) ||
        user.has_role?(:editor, c) ||
        user.has_role?(:manager, c)
    end

    can :view, TableState do |s|
      can?(:view, s.base)
    end
    can :manage, TableState do |s|
      can?(:change, s.base)
    end

    can :list,   Instance
    can :select, Instance do |instance|
      user.has_role?(:member, instance)
    end

    # Updating the user's details
    can :update, User, id: user.id
  end
end
