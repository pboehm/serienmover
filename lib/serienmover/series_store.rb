require 'find'
require 'serienrenamer'

module Serienmover

  # class that holds information from the series directories and has
  # some methods for accessing this index. It is possible to search for
  # a target for an episode
  class SeriesStore

    attr_reader :series_data, :series_dirs
    alias_method :series, :series_data

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

    # tries to find a suitable directory for this episode based on previous
    # added episodes. For now it will only uses directories where the previous
    # episode exists.
    #
    # returns an array of possible targets
    def find_suitable_target(episode)
      raise ArgumentError, "Serienrenamer::Episode needed" unless
          episode.is_a? Serienrenamer::Episode

      targets = []
      current = SeriesStore.build_index(episode.season, episode.episode)
      before  = SeriesStore.build_index(episode.season, episode.episode-1)

      series_data.each do |series, episodes|
          target_directory = nil

          if episode.episode <= 1
            # find the possible targets for a new season
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

              target_directory =
                File.join( File.dirname(season_before_dir), dir_part )
            end

          elsif episodes.include?(before) && ! episodes.include?(current)
            # look for the episode before the current which
            # should be not existant
            target_directory = File.dirname(episodes[before])

          elsif ! episodes.include?(before) && ! episodes.include?(current)
            # look for episodes that are released out of order so that
            # S05E10 is released before S05E07, for which we are searching
            # for a target
            episode.episode.upto(40).each do |e|
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

    # set the supplied target as used so that in future searches these
    # target will not be used
    def set_target_to_used(episode, target)
      raise ArgumentError, "Serienrenamer::Episode needed" unless
          episode.is_a? Serienrenamer::Episode
      raise ArgumentError, "Serienmover::EpisodeTarget needed" unless
          target.is_a? Serienmover::EpisodeTarget

      index = SeriesStore.build_index(episode.season, episode.episode)
      @series_data[target.series][index] =
          File.join(target.targetdir, episode.to_s)
    end

    # returns the index 'd_d', where the d's are the supplied
    # season and episode
    def self.build_index(season, episode)
      return '%d_%d' % [ season.to_i, episode.to_i ]
    end

  end

  # class that holds information about suitable target directories
  class EpisodeTarget
    attr_accessor :series, :targetdir

    def initialize(seriesname, targetdir)
      @series = seriesname
      @targetdir = targetdir
    end
  end
end
