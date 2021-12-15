require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative 'ruby/library/shell_executor'
require_relative 'ruby/workers_hub'
require_relative 'ruby/pipeline_starter'

module SwiftFormat
  class FormatWorker
    attr_accessor :tool,:configuration_path, :input_path
    def initialize(tool, configuration_path, input_path)
      self.tool = tool
      self.configuration_path = configuration_path
      self.input_path = input_path
    end
    def work
      action = "#{tool} -i --configuration #{configuration_path} #{input_path}"
      ShellExecutor.run_command_line action
    end
  end
end

module SwiftFormat
  module Configuration
    module Commands
      class FormatCommand
      end
    end
  end
end

module SwiftFormat::Pipeline
  class FormatPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        SwiftFormat::TravelerWorker.new(options[:toolPath]).work
      end
      SwiftFormat::FormatWorker.new(options[:toolPath], options[:configurationFilePath], options[:inputFilePath]).work
    end
  end
end

module SwiftFormat::Pipeline
  class CompoundPipeline < BasePipeline
    def self.start(options)
      puts "Lets find your command in a list..."
      case options[:command]
      when SwiftFormat::Configuration::Commands::FormatCommand then FormatPipeline.start(options)
      else
        puts "I don't recognize this command: #{options[:command]}"
        return
      end
    end
  end
  def self.start(options)
    CompoundPipeline.start(options)
  end
end

class MainWork
  class << self
    def work(arguments)
      work = new
      work.work(work.parse_options(arguments))
    end
  end

  # fixing arguments
  def fix_options(options)
    options
  end
  def required_keys
    [:inputFilePath]
  end
  def valid_options?(options)
    # true
    (required_keys - options.keys).empty?
  end

  def work(options = {})
    options = fix_options(options)

    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(1)
    end

    SwiftFormat::Pipeline.start(options)
  end

  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        options = {
          # commands
          command: SwiftFormat::Configuration::Commands::FormatCommand.new,
          # paths
          configurationFilePath: "#{__dir__}/../Tools/swift-format-configuration.json",
          toolPath: "#{__dir__}/../Tools/swift-format"
        }
      end

      def filePathOptions
        [
          :configurationFilePath,
          :toolPath,
          :inputFilePath,
        ]
      end

      def fixOptions(options)
        result_options = options
        filePathOptions.each do |v|
          unless result_options[v].nil?
            result_options[v] = File.expand_path(result_options[v])
          end
        end
        result_options
      end

      def generate(arguments, options)
        result_options = defaultOptions.merge options
        fixOptions(result_options)
      end

      def populate(arguments, options)
        new_options = self.generate(arguments, options)
        new_options = new_options.merge(options)
        fixOptions(new_options)
      end
    end
  end

  def help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you format swift files by `swift-format` utility.

    It have one required argument: `--inputFilePath PATH`.

    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    1. Only --inputFilePath provided.
    ruby #{$0} --inputFilePath <PATH>

    # or if you want Siri Voice, set environment variable SIRI_VOICE=1
    SIRI_VOICE=1 ruby #{$0}

    Run without parameters will active default configuration and script will format your file.

    DefaultConfiguration: #{JSON.pretty_generate(DefaultOptionsGenerator.defaultOptions)}
    __HELP__
  end

  def parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}

      # path
      opts.on('--inputFilePath', '--inputFilePath PATH', 'Input file to format.') {|v| options[:inputFilePath] = v}
      opts.on('--configurationFilePath', '--configurationFilePath PATH', 'File with configuration') {|v| options[:configurationFilePath] = v}
      opts.on('--toolPath', '--toolPath PATH', 'Path to format tool') {|v| options[:toolPath] = v}

    end.parse!(arguments)
    DefaultOptionsGenerator.populate(arguments, options)
  end
end

MainWork.work(ARGV)