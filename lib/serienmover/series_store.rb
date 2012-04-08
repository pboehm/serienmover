require 'find'
require 'serienrenamer'

module Serienmover

  # Public: holds information from the series directories and is able to
  #         search for possible targets for an supplied episode
  class SeriesStore

    attr_reader :series_data, :series_dirs
    alias_method :series, :series_data

    # Public: Initialize a SeriesStore
    #
    # series_directories - array of Strings that contains the
    #                      series_directories
    def initialize(series_directories)

      @series_data = {}
      @series_dirs = []

      series_directories.each do |series_directory|
        next unless File.directory? series_directory
        @series_dirs << series_directory

        Dir.new(series_directory).each do |series|
          next if series.match(/^\.*$/)

          seriesdir = File.join(series_directory, series)

          episodes = {}
          Find.find(seriesdir) do |file|
            next unless File.file?(file)

            infos = Serienrenamer::Episode.extract_episode_information(
              File.basename(file))

            if infos
              index = SeriesStore.build_index(infos[:season], infos[:episode])
              episodes[index] = file
            end
          end

          series_data[series] = episodes
        end
      end
    end

    # Public: finds a suitable target in the store
    #
    # episode  - Serienrenamer::Episode instance
    # options  - optional arguments (default: {):}
    #            :series  - if this option is set than it returns only targets
    #                       where the series matches the supplied arguments
    #
    # Returns an array of EpisodeTargets
    def find_suitable_target(episode, options = {})
      raise ArgumentError, "Serienrenamer::Episode needed" unless
          episode.is_a? Serienrenamer::Episode

      targets = []
      current = SeriesStore.build_index(episode.season, episode.episode)
      before  = SeriesStore.build_index(episode.season, episode.episode-1)

      series_data.each do |series, episodes|

        # restrict series to the supplied seriesname and skip otherwise
        if options.include?(:series) && options[:series].match(/\w+/)
          next unless SeriesStore.does_match_series?(series, options[:series])
        end

        target_directory = nil

        if episode.episode <= 1
          # find possible targets for a new season
          current_season = episodes.select do |e|
            ! e.match(/^#{episode.season.to_s}_/).nil?
          end
          before_season = episodes.select do |e|
            ! e.match(/^#{(episode.season-1).to_s}_/).nil?
          end

          if current_season.empty? && ! before_season.empty?
            season_before_dir = File.dirname(before_season.values[0])

            dir_part = File.basename(season_before_dir)
            dir_part.gsub!(/#{(episode.season-1).to_s }/, episode.season.to_s)

            # let 'Staffel 010' be 'Staffel 10' as a side effect of
            # the regex before
            dir_part.gsub!(/010/, '10')

            target_directory =
              File.join( File.dirname(season_before_dir), dir_part )
          end

        elsif episodes.include?(before) && ! episodes.include?(current)
          # look for the episode before the current which
          # should be not existant and which hash no seasons afterwards

          # check for seasons that follows the current
          episodes_of_following_seasons =
            episodes.select { |e| e.match(/#{(episode.season + 1).to_s}_/) }

          if episodes_of_following_seasons.empty?
            target_directory = File.dirname(episodes[before])
          end

        elsif ! episodes.include?(before) && ! episodes.include?(current)
          # look for episodes that are released out of order so that
          # S05E10 is released before S05E07, for which we are searching
          # for a target
          episode.episode.upto(50).each do |e|
            index = SeriesStore.build_index(episode.season, e)
            if episodes.include?(index)
              target_directory = File.dirname(episodes[index])
            end
          end
        end

        # build up target instance
        if target_directory
          target = EpisodeTarget.new(series, target_directory)
          targets << target
        end
      end

      targets
    end


    # Public: set the supplied target as used so that it is not
    #         available for future searches
    #
    # episode - Serienrenamer::Episode instcnace
    # target  - EpisodeTarget instance
    #
    # Returns nothing
    def set_target_to_used(episode, target)
      raise ArgumentError, "Serienrenamer::Episode needed" unless
          episode.is_a? Serienrenamer::Episode
      raise ArgumentError, "Serienmover::EpisodeTarget needed" unless
          target.is_a? Serienmover::EpisodeTarget

      index = SeriesStore.build_index(episode.season, episode.episode)
      @series_data[target.series][index] =
          File.join(target.targetdir, episode.to_s)
    end

    class << self

      # Public: tries to match the suppplied seriesname pattern
      #         agains the series
      #
      # seriesname     - the seriesname that comes from the series_directory
      # series_pattern - the series_name that has to be checked
      #                  agains the seriesname
      #
      # Returns true if it matches otherwise false
      def does_match_series?(seriesname, series_pattern)

        if seriesname.match(/#{series_pattern}/i)
          # if pattern matches the series directly
          return true

        else
          # start with a pattern that includes all words from
          # series_pattern and if this does not match, it cuts
          # off the first word and tries to match again
          #
          # if the pattern contains one word and if this
          # still not match, the last word is splitted
          # characterwise, so that:
          #  crmi ==> Criminal Minds
          name_words = series_pattern.split(/ /)
          word_splitted = false

          while ! name_words.empty?

            pattern = name_words.join('.*')
            return true if seriesname.match(/#{pattern}/i)

            # split characterwise if last word does not match
            if name_words.length == 1 && ! word_splitted
              name_words = pattern.split(//)
              word_splitted = true
              next
            end

            # if last word was splitted and does not match than break
            # and return empty resultset
            break if word_splitted

            name_words.delete_at(0)
          end
        end

        false
      end

      # Public: builds up an index 'd_d' where the d's are the supplied args
      #
      # season - Number that is the first part of the 'd_d'
      # season - Number that is the second part of 'd_d'
      #
      # Examples
      #
      #   build_index('09', '12')
      #   # => '9_12'
      #
      # Returns the index
      def build_index(season, episode)
        return '%d_%d' % [ season.to_i, episode.to_i ]
      end

    end
  end

  # Public: holds information about suitable target directories
  #
  # Examples
  #
  #   target = EpisodeTarget.new('Chuck', '/path/to/series')
  #   target.series
  #   # => "Chuck"
  #
  class EpisodeTarget
    attr_accessor :series, :targetdir

    def initialize(seriesname, targetdir)
      @series = seriesname
      @targetdir = targetdir
    end

    def to_s
      @series
    end
  end
end
