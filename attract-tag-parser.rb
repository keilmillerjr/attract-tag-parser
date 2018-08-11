#! /usr/bin/env ruby
# make sure file is executable with chmod u+x FILE_PATH

require 'optparse'
require 'nokogiri'
require 'fileutils'

# options
ARGV << '-h' if ARGV.empty?

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: attract-tag-parser.rb [OPTIONS]"

  opts.on('-l', '--taglist TAGLIST', 'Taglist file path *REQUIRED*') do |taglist_path|
    options[:taglist_path] = taglist_path
  end

  opts.on('-x', '--xml XML', 'mame.xml file path') do |xml_path|
    options[:xml_path] = xml_path
  end

  opts.on('-b', '--buttons BUTTONS', 'Filter by button count of equal or lesser value') do |buttons|
    options[:buttons] = buttons.to_i
  end

  opts.on('-s', '--source SOURCE', 'Source folder path') do |source_path|
    options[:source_path] = source_path
  end

  opts.on('-t', '--target TARGET', 'Target folder path') do |target_path|
    options[:target_path] = target_path
  end

  opts.on('-h', '--help', 'Display help') do
    puts opts
    exit
  end
end.parse!

# Taglist class
class Taglist
  attr_reader :list

  def initialize(taglist_path)
    # define list
    @list = IO.readlines(taglist_path)
    @list = @list.collect(&:strip)
    @list.sort!
    @list.collect! { |rom| { name: rom, description: nil, buttons: nil, match: nil } }
  end

  def add_xml(xml_path)
    xml_doc = Nokogiri::XML(File.read(xml_path))
    xml_doc.remove_namespaces!

    @list.each do |rom|
      rom[:description] = xml_doc.at_xpath("/mame/machine[@name='#{rom[:name]}']/description").text

      xml_buttons = xml_doc.xpath("/mame/machine[@name='#{rom[:name]}']/input/control").first.attribute('buttons')
      xml_buttons.nil? ? rom[:buttons] = 0 : rom[:buttons] = xml_buttons.text.to_i
    end
  end

  def filter_by_buttons(max)
    @list.delete_if { |rom|
      rom[:buttons] > max
    }
  end

  def audit(source_path)
    @list.each do |rom|
      Dir.glob(source_path + '/' + rom[:name] + '.*') do
        rom[:match] = true
      end

      rom[:match] = false if rom[:match].nil?
    end
  end

  def show()
    header_name = "NAME"
    longest_name = @list.max_by { |rom| rom[:name].length }
    charspace_name = longest_name[:name].length > header_name.length ? longest_name[:name].length : header_name.length

    header_description = "DESCRIPTION"
    longest_description = @list.max_by { |rom| rom[:description].to_s.length }
    charspace_description = longest_description[:description].to_s.length > header_description.length ? longest_description[:description].length : header_description.length

    header_buttons = "BUTTONS"
    longest_buttons = @list.max_by { |rom| rom[:buttons].to_s.length }
    charspace_buttons = longest_buttons[:buttons].to_s.length > header_buttons.length ? longest_buttons[:buttons].length : header_buttons.to_s.length

    header_match = "MATCH"
    charspace_match = header_match.length

    printf("%-#{charspace_name}s %-#{charspace_description}s %-#{charspace_buttons}s %s\n", "#{header_name}", "#{header_description}", "#{header_buttons}", "#{header_match}")

    @list.each do |rom|
      printf("%-#{charspace_name}s %-#{charspace_description}s %-#{charspace_buttons}s %s\n", "#{rom[:name]}", "#{rom[:description]}", "#{rom[:buttons]}", "#{rom[:match]}")
    end

    puts
    puts "Total: #{@list.count}"
    puts "Found: #{@list.count{ |rom| rom[:match] }}"
    puts "Missing: #{@list.count{ |rom| !rom[:match] }}"
  end

  def copy_files(source_path, target_path)
    count = 0
    @list.each do |rom|
      Dir.glob(source_path + '/' + rom[:name] + '.*') do |filename|
        puts "Copying #{File.basename(filename).to_s}"
        FileUtils.cp File.expand_path(filename), target_path
        count += 1
      end
    end

    puts ""
    puts "Copied: #{count}"
  end
end

# create Taglist
taglist = Taglist.new(options[:taglist_path])

# modify list
taglist.add_xml(options[:xml_path]) if options[:xml_path]
taglist.filter_by_buttons(options[:buttons]) if options[:buttons]
taglist.audit(options[:source_path]) if options[:source_path]

# Taglist actions
if options[:source_path] && options[:target_path]
  taglist.copy_files(options[:source_path], options[:target_path])
else
  taglist.show()
end

# exit ruby script
exit
