require File.dirname(__FILE__) + '/../spec_helper'

describe Symbol do
  it "goes to_proc" do
    [:a, :b, :c].map(&:to_s).should == %w(a b c)
  end
end