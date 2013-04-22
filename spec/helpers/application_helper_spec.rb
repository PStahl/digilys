require 'spec_helper'

describe ApplicationHelper do
  describe "#bootstrap_flash" do
    it "does not print anything when there are no flash messages" do
      helper.bootstrap_flash.should be_blank
    end
    it "only prints flash messages that have been set" do
      flash[:error] = "Error message"
      flash[:info]  = "Info message"
      result        = helper.bootstrap_flash
      result.should     match(/Error message/)
      result.should     match(/Info message/)
      result.should_not match(/alert-(success|warning)/)
    end
    it "uses bootstrap classes" do
      flash[:error] = "Error message"
      result        = helper.bootstrap_flash
      result.should match(/class="[^"]*\balert[^-][^"]*"/)
      result.should match(/class="[^"]*\balert-error[^"]*"/)
    end
  end
end
