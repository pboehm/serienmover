require File.join(File.dirname(__FILE__), "spec_helper.rb")
require 'serienrenamer'

describe Serienmover do


  before(:each) do
    @episodes = TestData.create
  end

  after(:each) do
    TestData.clean
  end

  it "should build up Episode instances successfully" do
    @episodes[:tbbt].should_not be_nil
  end

  it "should extract the right information from the files" do
    @episodes[:crmi].episode.should eq 4
  end
end

