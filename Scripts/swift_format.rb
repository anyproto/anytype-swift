require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'
require_relative 'library/pipelines'
require_relative 'library/commands'

module SwiftFormat
  TravelerWorker = Workers::TravelerWorker
  ExternalToolWorker = Workers::ExternalToolWorker
  class ToolVersionWorker < ExternalToolWorker
    def action
      "#{tool} --version"
    end
  end
  class ToolHelpWorker < ExternalToolWorker
    def action
      "#{tool} --help"
    end
  end
  class FormatWorker < ExternalToolWorker
    attr_accessor :configuration_path, :input_path
    def initialize(tool_path, configuration_path, input_path)
      super(tool_path)
      self.configuration_path = configuration_path
      self.input_path = input_path
    end
    def action
      "#{tool} -i --configuration #{configuration_path} #{input_path}"
    end
  end
end

module SwiftFormat
  module Configuration
    BaseCommand = Commands::BaseCommand
    module Commands
      class ToolVersionCommand < BaseCommand
      end
      class ToolHelpCommand < BaseCommand
      end
      class FormatCommand < BaseCommand
      end
    end
    module EnvironmentVariables
    end
  end
end

module SwiftFormat
  module Pipeline
    BasePipeline = Pipelines::BasePipeline
  end
end

module SwiftFormat::Pipeline
  class ToolVersionPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        SwiftFormat::TravelerWorker.new(options[:toolPath]).work
      end
      puts SwiftFormat::ToolVersionWorker.new(options[:toolPath]).work
    end
  end
end

module SwiftFormat::Pipeline
  class ToolHelpPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        SwiftFormat::TravelerWorker.new(options[:toolPath]).work
      end
      puts SwiftFormat::ToolHelpWorker.new(options[:toolPath]).work
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
      say "Lets find your command in a list..."
      case options[:command]
      when SwiftFormat::Configuration::Commands::FormatCommand then FormatPipeline.start(options)
      when SwiftFormat::Configuration::Commands::ToolVersionCommand then ToolVersionPipeline.start(options)
      when SwiftFormat::Configuration::Commands::ToolHelpCommand then ToolHelpPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        finalize
        return
      end
      finalize
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
    case options[:command]
    when SwiftFormat::Configuration::Commands::ToolVersionCommand then true
    when SwiftFormat::Configuration::Commands::ToolHelpCommand then true
    else
      (required_keys - options.keys).empty?
    end
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

      opts.on('-v', '--version', 'Version of tool') {|v| options[:command] = SwiftFormat::Configuration::Commands::ToolVersionCommand.new}
      opts.on('-t', '--toolHelp', 'Tool help') {|v| options[:command] = SwiftFormat::Configuration::Commands::ToolHelpCommand.new}
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