class Result < ActiveRecord::Base
  belongs_to :evaluation
  belongs_to :student

  attr_accessible :evaluation_id, :student_id, :value

  validates :value, numericality: {
    only_integer:             true,
    greater_than_or_equal_to: 0,
    less_than_or_equal_to:    ->(result) { result.evaluation.max_result }
  }
  validates :evaluation, :student, presence: true
end