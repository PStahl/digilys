FactoryGirl.define do
  factory :user do
    sequence(:email)      { |i| "user%09d@example.com" % i }
    password              "password"
    password_confirmation { password }

    factory :admin do
      after(:create) { |user| user.add_role :admin }
    end
  end

  factory :student do
    sequence(:name) { |i| "Student %09d" % i }
  end

  factory :group do
    sequence(:name) { |i| "Group %09d" % i }
    parent          nil
  end

  factory :suite do
    template        nil
    sequence(:name) { |i| "Suite %09d" % i }
    is_template     false
  end

  factory :participant do
    student
    suite
  end

  factory :evaluation do
    template        nil
    suite           nil
    sequence(:name) { |i| "Evaluation %09d" % i }
    date            Date.today
    max_result      50
    red_below       15
    green_above     35

    ignore do
      stanines      [7, 12, 17, 22, 27, 32, 37, 42]
    end

    stanine1        { stanines ? stanines[0] : nil }
    stanine2        { stanines ? stanines[1] : nil }
    stanine3        { stanines ? stanines[2] : nil }
    stanine4        { stanines ? stanines[3] : nil }
    stanine5        { stanines ? stanines[4] : nil }
    stanine6        { stanines ? stanines[5] : nil }
    stanine7        { stanines ? stanines[6] : nil }
    stanine8        { stanines ? stanines[7] : nil }

    factory :evaluation_with_suite do
      suite
    end
  end

  factory :result do
    evaluation
    student
    value   25
    color   nil
    stanine nil
  end

  factory :meeting do
    suite
    sequence(:name) { |i| "Meeting %09d" % i }
    date            Date.today
    completed       false
    notes           nil
  end
end
