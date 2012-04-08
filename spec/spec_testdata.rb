require File.join(File.dirname(__FILE__), "spec_helper.rb")

class TestData

  EPISODES = {
    :chuck => { :filename => "S04E11 - Pilot.avi",
                :series => "Chuck",
                :data => { :from => '1_1', :to => '4_10' }
    },
    :tbbt  => { :filename => "S05E06 - Pilot.avi",
                :series => "The Big Bang Theory",
                :data => { :from => '1_1', :to => '5_9',
                           :exclude => ['5_5', '5_6', '5_7', '5_8', ] }
    },
    :crmi  => { :filename => "S01E04 - Pilot.avi",
                :series => "Criminal Minds",
                :data => { :from => '1_1', :to => '1_3' }
    },
    :seap  => { :filename => "S01E04 - Pilot.avi",
                :series => "Sea Patrol",
                :data => { :from => '1_1', :to => '1_3' }
    },
    :drhou => { :filename => "S05E01 - First Episode.avi",
                :series => "Dr House",
                :data => { :from => '1_1', :to => '4_20' }
    },
    :spook => { :filename => "S10E01 - First Episode.avi",
                :series => "Spooks",
                :data => { :from => '1_1', :to => '9_20' }
    },
    :numbe => { :filename => "S04E31 - High Episode.avi",
                :series => "Numb3rs",
                :data => { :from => '1_1', :to => '4_30' }
    },
  }

  # create test data
  def self.create
    episodes = Hash.new

    EPISODES.each do |key,value|
      TestHelper.create_test_files([ value[:filename] ])
      TestHelper.create_series(value[:series], value[:data])

      path = TestHelper.path(value[:filename])
      episode = Serienrenamer::Episode.new(path)

      episodes[key] = episode
    end
    return episodes
  end

  # remove files
  def self.clean
    TestHelper.clean
  end

  def self.get(key)
    EPISODES[key]
  end

end
