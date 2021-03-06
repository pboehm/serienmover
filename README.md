# Serienmover [![Build Status](https://secure.travis-ci.org/pboehm/serienmover.png)](http://travis-ci.org/pboehm/serienmover)

Tool that moves series episodes into a specific directory structure.
It's recommended to use [serienrenamer](http://github.com/pboehm/serienrenamer)
to rename these files.

## Installation

    $ gem install serienmover

That installs an executable named `serienmover` that is used to
process the files.

## Features

*   searches for a possible target in your series directories
*   can read a Yaml file from `serienrenamer` which holds the series names
    from the renamed files, indexed by md5sum
*   creates a new season directory if episode is the first of a new season
    by detecting the pattern from former seasons
*   has some metrics to find mostly the right target
*   can process the series automatic by file
*   can execute a script for every copied episode

## Usage

    $ serienmover

## Configuration

You can change the behaviour of `serienmover` with commandline arguments
(`serienmover --help` for an overview) or by editing the config file
under `~/.serienmover/config.yml`.

An overview of the supported configuration values follows:

### default_directory
Directory that is used by default, to look for new episodes
(Default: ~/Downloads/).

### series_directories
An array of paths to directories which contains the series.

### read_episode_info
Read the seriesname from a file, that is created by `serienrenamer`. The path
to the file is set by `store_path`.

### byte_count_for_md5
A number of bytes that is used to generate the md5sum. The count has to match
with the setting from `serienrenamer`. Defaults to `2048`.

### post_copy_hook
This can hold a path to a script, that is called for all copied episodes
after they have copied. By creating this script, you can automate some things
like, hold all copied files in a separate directory. This file has to be
executable and there are two parameters supplied:
    1) the episodefile 2) the seriesname

### auto_process_enable
Should `serienmover` decide automatically which action (copy/move) should be
applied on the episodes.

### auto_default_action
This is the default action, that `serienmover` will apply, when the previous
setting is true.

### auto_exceptions
A list of series that will have the opposite default action. When
`auto_default_action` is `:copy` than the default action is `:move`, and vice
versa.
