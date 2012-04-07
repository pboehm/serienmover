require 'bundler/setup'
require 'fileutils'
require 'rspec'

require File.dirname(__FILE__) + '/../lib/serienmover'
require File.join(File.dirname(__FILE__), "spec_testdata.rb")

RSpec.configure do |config|
end

class TestHelper

  TESTFILE_DIRECTORY = File.join(File.dirname(__FILE__), 'testfiles')
  SERIES_STORAGE_DIR = File.join(TESTFILE_DIRECTORY, 'series')

  class << self

    # create the supplied Files in the testfiles directory
    def create_test_files(files)
      _create_directories

      files.each do |f|
        FileUtils.touch File.join(TESTFILE_DIRECTORY, f)
      end
    end

    # this method creates a directory structure for a given
    # series with the opportunity to exclude some episodes
    def create_series(seriesname, options={})
      default = { :from => '1_0', :to => '1_0',
                  :max => 30, :exclude => [] }
      options = default.merge(options)

      series_dir = File.join(SERIES_STORAGE_DIR, seriesname)
      _create_dir(series_dir)

      from = _split_entry(options[:from])
      to   = _split_entry(options[:to])

      for season in from[0]..to[0]

        season_dir = File.join(series_dir, "Staffel %02d" % season)
        _create_dir(season_dir)

        episodes = (season == to[0]) ? to[1] : options[:max]

        for episode in 1..episodes.to_i

          # check for excludes
          definition = "%d_%d" % [ season, episode ]
          next if options[:exclude].include? definition

          # build and create file
          file = "S%02dE%02d - Epi%02d.avi" % [ season, episode,episode ]
          episode_file = File.join(season_dir, file)
          _create_file(episode_file)
        end
      end


    end

    # returns the absolute path to the given file
    def path(element)
      File.absolute_path(File.join(TESTFILE_DIRECTORY, element))
    end

    # remove testfile directory
    def clean
      if File.directory?(TESTFILE_DIRECTORY)
        FileUtils.remove_dir(TESTFILE_DIRECTORY)
      end
    end

    def _split_entry(definition)
      definition.split(/_/)
    end

    def _create_directories
      _create_dir TESTFILE_DIRECTORY
      _create_dir SERIES_STORAGE_DIR
    end

    def _create_dir(dir)
      FileUtils.mkdir(dir) unless File.directory?(dir)
    end

    def _create_file(file)
      FileUtils.touch(file) unless File.file?(file)
    end
  end
end
