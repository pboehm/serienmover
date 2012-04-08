require File.join(File.dirname(__FILE__), "spec_helper.rb")
require 'serienrenamer'

describe Serienrenamer::Episode do

  before(:each) do
    @episodes = TestData.create

    @store = Serienmover::SeriesStore.new([ TestHelper::SERIES_STORAGE_DIR ])
  end

  after(:each) do
    TestData.clean
  end

  it "should copy the episode properly" do
    episode = @episodes[:crmi]

    results = @store.find_suitable_target(episode, series: "Criminal Minds")
    results.size.should be == 1
    results[0].series.should eq "Criminal Minds"

    target = results[0]
    episode.target = target
    episode.set_action(copy: true)
    episode.process_action

    File.file?(episode.episodepath).should be_true

    remote_path = File.join(target.targetdir, File.basename(episode.episodepath))
    File.file?(remote_path).should be_true
  end

  it "should move the episode properly" do
    episode = @episodes[:crmi]

    results = @store.find_suitable_target(episode, series: "Criminal Minds")
    results.size.should be == 1
    results[0].series.should eq "Criminal Minds"

    target = results[0]
    episode.target = target
    episode.set_action(move: true)
    episode.process_action

    File.file?(episode.episodepath).should_not be_true

    remote_path = File.join(target.targetdir, File.basename(episode.episodepath))
    File.file?(remote_path).should be_true
  end
end
