# Serienmover

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

## Usage

    $ serienmover

## Configuration

You can change the behaviour of `serienmover` with commandline arguments
(`serienmover --help` for an overview) or by editing the config file
under `~/.serienmover/config.yml`.

