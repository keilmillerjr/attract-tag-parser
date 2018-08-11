# attract tag parser for AttractMode front end

by Keil Miller Jr [Keil Miller Jr](http://keilmiller.com)

## DESCRIPTION:

*attract tag parser* is a ruby script that allows you to list tags for the [AttractMode](http://attractmode.org) front end, audit local files, and copy matches. This allows you to easily create slim romsets and media files in an automated way. Using non-merged romsets when parsing for rom files would be best as there is no clone/parent logic.

## Requirements:

* [ruby](https://www.ruby-lang.org/en/) tested using version 2.5.0
* [nokogiri](http://www.nokogiri.org) gem for parsing XML
* AttractMode tag lists *consider using [Attract Tags](https://github.com/keilmillerjr/attract-tags)*

## Environment

I use [Ruby Version Manager](http://rvm.io), installed ruby version 2.5.0, and created an isolated gemset. It's a good practice for other projects you may have. I am using Mac OS X. RVM is now available for most UNIX systems and Windows. I am not familiar with setting it up on windows. Read the RVM documentation.

1. [Install rvm stable](http://rvm.io/rvm/install)
2. ```$ rvm install 2.5.0p0```
3. ```$ rvm default use 2.5.0p0```
4. ```$ rvm gemset create attract-tag-parser```
5. ```$ rvm gemset use attract-tag-parser```
6. ```$ gem install nokogiri```

## Usage

```$ ruby attract-tag-parser.rb```

This will provide the following help.

```
Usage: attract-tag-parser.rb [OPTIONS]
    -l, --taglist TAGLIST            Taglist file path *REQUIRED*
    -x, --xml XML                    mame.xml file path
    -b, --buttons BUTTONS            Filter by button count of equal or lesser value
    -s, --source SOURCE              Source folder path
    -t, --target TARGET              Target folder path
    -h, --help                       Display help
```

* Default behavior is to show taglist, description, buttons, and match.
* When SOURCE and TARGET is passed, matches will be copied from source to target.