class Suite < ActiveRecord::Base
  resourcify

  belongs_to :instance
  belongs_to :template,  class_name: "Suite"
  has_many   :children,
    class_name:  "Suite",
    foreign_key: "template_id",
    dependent:   :nullify

  has_many :users,        through: :roles,        uniq: true,          order: "name asc, email asc"
  has_many :participants, inverse_of: :suite,     include: :student,   dependent: :destroy
  has_many :students,     through: :participants
  has_many :groups,       through: :students,     order: "groups.name asc", uniq: true
  has_many :evaluations,  inverse_of: :suite,     order: "date asc",   dependent: :destroy
  has_many :series,                               order: "name asc",   dependent: :destroy
  has_many :results,      through: :evaluations
  has_many :meetings,     inverse_of: :suite,     dependent: :destroy
  has_many :activities,   inverse_of: :suite,     order: "start_date asc nulls last, end_date asc nulls last, name asc",   dependent: :destroy
  has_many :table_states,  as: :base,             order: "name asc",   dependent: :destroy

  accepts_nested_attributes_for :evaluations,
    :meetings,
    :participants

  attr_accessible :name,
    :is_template,
    :template_id,
    :instance,
    :instance_id,
    :evaluations_attributes,
    :meetings_attributes,
    :participants_attributes

  validates :name,     presence: true
  validates :instance, presence: true

  serialize :generic_evaluations, JSON
  serialize :student_data,        JSON


  def generic_evaluations
    if read_attribute(:generic_evaluations).nil?
      write_attribute(:generic_evaluations, [])
    end
    return read_attribute(:generic_evaluations)
  end
  def student_data
    if read_attribute(:student_data).nil?
      write_attribute(:student_data, [])
    end
    return read_attribute(:student_data)
  end

  def group_hierarchy
    partition = self.groups.group_by(&:parent_id)

    sorted_groups = []

    # The top level has parent_id == nil
    sort_partitioned_groups(sorted_groups, partition, nil)
    return sorted_groups
  end

  def update_evaluation_statuses!
    self.evaluations(true).each { |e| e.update_status! }
  end


  def self.template
    where(is_template: true)
  end
  def self.regular
    where(is_template: false)
  end

  def self.new_from_template(template, attrs = {})
    new do |s|
      s.name = template.name

      s.assign_attributes(attrs)

      template.evaluations.each do |evaluation|
        s.evaluations << Evaluation.new_from_template(evaluation)
      end

      template.meetings.each do |meeting|
        s.meetings.build(name: meeting.name)
      end
    end
  end


  private

  def sort_partitioned_groups(sorted_groups, partition, key)
    return if partition[key].blank?

    partition[key].each do |group|
      sorted_groups << group
      sort_partitioned_groups(sorted_groups, partition, group.id)
    end
  end

end
