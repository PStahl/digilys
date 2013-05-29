require 'spec_helper'

describe Activity do
  context "factory" do
    subject { build(:activity) }
    it      { should be_valid }

    context "for action activity" do
      subject { build(:action_activity) }
      it      { should be_valid }
    end
    context "for inquiry activity" do
      subject { build(:inquiry_activity) }
      it      { should be_valid }
    end
  end
  context "accessible attributes" do
    it { should allow_mass_assignment_of(:suite_id) }
    it { should allow_mass_assignment_of(:type) }
    it { should allow_mass_assignment_of(:status) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:notes) }
  end
  context "validation" do
    it { should validate_presence_of(:suite) }
    it { should validate_presence_of(:name) }
    it { should ensure_inclusion_of(:type).in_array(%w(action inquiry)) }
    it { should ensure_inclusion_of(:status).in_array(%w(open closed)) }
  end

  describe ".set_suite_from_meeting" do
    let(:suite)        { nil }
    let(:meeting)      { create(:meeting) }
    subject(:activity) { build(:activity, suite: suite, meeting: meeting)}
    before(:each)      { activity.valid? }

    its(:suite) { should == meeting.suite }

    context "with existing suite" do
      let(:suite) { create(:suite) }
      its(:suite) { should == suite }
    end
  end

  describe ".parse_students_and_groups" do
    let!(:students)           { create_list(:student, 3) }
    let!(:groups)             { create_list(:group,   3) }
    let(:students_and_groups) { nil }
    subject(:activity)        { create(:activity, students_and_groups: students_and_groups) }

    its(:students) { should be_blank }
    its(:groups)   { should be_blank }

    context "with student ids" do
      let(:students_and_groups) { students.collect { |s| "s-#{s.id}" }.join(",") }
      its(:students)            { should match_array(students) }
    end
    context "with group ids" do
      let(:students_and_groups) { groups.collect { |g| "g-#{g.id}" }.join(",") }
      its(:groups)              { should match_array(groups) }
    end
    context "with student and group ids" do
      let(:students_and_groups) { "s-#{students.first.id},g-#{groups.first.id}"}
      its(:students)            { should == [students.first] }
      its(:groups)              { should == [groups.first] }
    end
    context "with invalid data" do
      let(:students_and_groups) { "[],zomg,123,s-#{students.first.id},g-#{groups.first.id}"}
      its(:students)            { should == [students.first] }
      its(:groups)              { should == [groups.first] }
    end
    context "with duplicates" do
      let(:students_and_groups) { ([ "s-#{students.first.id}", "g-#{groups.first.id}" ] * 2).join(",") }
      its(:students)            { should == [students.first] }
      its(:groups)              { should == [groups.first] }
    end
  end
  describe ".students_and_groups_select2_data" do
    let(:students)     { create_list(:student, 3) }
    let(:groups)       { create_list(:group,   3) }
    subject(:activity) { create(:activity, students: students, groups: groups) }

    its(:students_and_groups_select2_data) { should have(6).items }
    its(:students_and_groups_select2_data) { should include(id: "s-#{students.first.id}",  text: students.first.name) }
    its(:students_and_groups_select2_data) { should include(id: "s-#{students.second.id}", text: students.second.name) }
    its(:students_and_groups_select2_data) { should include(id: "s-#{students.third.id}",  text: students.third.name) }
    its(:students_and_groups_select2_data) { should include(id: "g-#{groups.first.id}",    text: groups.first.name) }
    its(:students_and_groups_select2_data) { should include(id: "g-#{groups.second.id}",   text: groups.second.name) }
    its(:students_and_groups_select2_data) { should include(id: "g-#{groups.third.id}",    text: groups.third.name) }
  end
end