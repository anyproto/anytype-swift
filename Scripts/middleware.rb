require 'optparse'
require 'shellwords'
require 'pathname'

require 'tmpdir'

require 'net/http'

require 'yaml'
require 'json'

require_relative 'ruby/middleware_updater'
require_relative 'ruby/options_parser'

class MainWork
  class << self
    def work(arguments)
      options = OptionsParser.new.parse_options(arguments)
      work = new
      work.work(options)
    end
  end

  # fixing arguments
  def fix_options(options)
    options
  end
  def required_keys
    []
  end
  def valid_options?(options)
    # true
    (required_keys - options.keys).empty?
  end

  def work(options = {})
    options = fix_options(options)

    if options[:inspection]
      puts "options are: #{options}"
    end

    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(1)
    end

    ShellExecutor.setup options[:dry_run]

    Pipeline.start(options)
  end
end

MainWork.work(ARGV)