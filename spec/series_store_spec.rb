require File.join(File.dirname(__FILE__), "spec_helper.rb")

describe Serienmover::SeriesStore do

  before(:each) do
    @episodes = TestData.create

    @store = Serienmover::SeriesStore.new([ TestHelper::SERIES_STORAGE_DIR ])
  end

  after(:each) do
    TestData.clean
  end

  it "should be possible to instantiate the store" do
    @store.should_not be_nil
  end

  it "should process the series directories" do
    @store.series_dirs.size > 0
  end

  it "should build up a hash for series with all episodes" do
    @store.series["Chuck"].size > 0
  end

  it "should return the right target for 'Chuck'" do
    episode = @episodes[:chuck]
    results = @store.find_suitable_target(episode)
    results.select { |t| t.series == "Chuck" }.size.should be >= 1
  end

  it "should return the right target for 'Criminal Minds'" do
    episode = @episodes[:crmi]
    results = @store.find_suitable_target(episode)
    results.select { |t| t.series == "Criminal Minds" }.size.should be >= 1
  end

  it "should return the right target for 'The Big Bang Theory'" do
    episode = @episodes[:tbbt]
    results = @store.find_suitable_target(episode)
    results.select { |t| t.series == "The Big Bang Theory" }.size.should be >= 1
  end

  it "should return the right target for 'Dr House'" do
    episode = @episodes[:drhou]
    results = @store.find_suitable_target(episode)
    results.select { |t| t.series == "Dr House" }.size.should be >= 1
  end

  it "should set target to used and skipped this target in future searches" do
    episode = @episodes[:crmi]
    results = @store.find_suitable_target(episode)
    results.size.should be 2

    crmi_target = results.select { |t| t.series == "Criminal Minds" }[0]
    @store.set_target_to_used(episode, crmi_target)

    episode = @episodes[:seap]
    less_results = @store.find_suitable_target(episode)
    less_results.size.should be 1
  end
end
