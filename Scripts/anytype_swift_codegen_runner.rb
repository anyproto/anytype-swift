# This script generate convenient interfaces and services for protobuf models.
# Steps.
# 1. Generate interfaces.
# 2. Generate services.

# Parameters
# 1. what to generate ( or all )
# 2. which files to generate ( or all )
# 3. which tool to choose ( or default tool )
# 4. where to generate files

require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'
require_relative 'library/pipelines'

module AnytypeSwiftCodegenRunner
  TravelerWorker = Workers::TravelerWorker
  class BaseWorker < Workers::BasicWorker
    attr_accessor :toolPath
    def initialize(toolPath)
      self.toolPath = toolPath
    end
    def is_directory?
      is_valid? && Dir.exists?(toolPath)
    end
    def is_valid?
      File.exists? toolPath
    end
    def tool
      "#{toolPath}"
    end
  end
  class CodegenWorker < BaseWorker
    attr_accessor :transform, :filePath
    def initialize(toolPath, transform, filePath)
      super(toolPath)
      self.transform = transform
      self.filePath = filePath
    end
    def action
      "ruby #{tool} --transform #{transform} --filePath #{filePath}"
    end
  end
  class FormatWorker < BaseWorker
    attr_accessor :filePath
    def initialize(toolPath, filePath)
      super(toolPath)
      self.transform = transform
      self.filePath = filePath
    end
    def action
      "ruby #{tool} --inputFilePath #{filePath}"
    end
  end
end

module AnytypeSwiftCodegenRunner
  module Configuration
    module Commands
      class BaseCommand
        def to_json(*args)
          self.class.name
        end
      end
      class CodegenCommand < BaseCommand
      end
      class CodegenListCommand < BaseCommand
        attr_accessor :list
        def initialize(options)
          self.list = options
        end
      end
    end
    module EnvironmentVariables
    end
  end
end

module AnytypeSwiftCodegenRunner
  module Pipeline
    BasePipeline = Pipelines::BasePipeline
  end
end

module AnytypeSwiftCodegenRunner::Pipeline
  class CodegenPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegenRunner::TravelerWorker.new(options[:toolPath]).work
      end
      AnytypeSwiftCodegenRunner::CodegenWorker.new(options[:toolPath], options[:transform], options[:filePath]).work
    end
  end
end

module AnytypeSwiftCodegenRunner::Pipeline
  class FormatDirectoryPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegenRunner::TravelerWorker.new(options[:toolPath]).work
      end
      Dir[options[:outputDirectory]].entries.select{|f| File.file?(f) && File.extname(f) == ".swift"}.map{|f| File.absolute_path(f)}.each{|f|
        AnytypeSwiftCodegenRunner::FormatWorker.new(options[:formatToolPath], f)
      }
    end
  end
end

module AnytypeSwiftCodegenRunner::Pipeline
  class CompoundPipeline < BasePipeline
    def self.start(options)
      say "Lets find your command in a list..."
      case options[:command]
      when AnytypeSwiftCodegenRunner::Configuration::Commands::CodegenCommand then CodegenPipeline.start(options)
      when AnytypeSwiftCodegenRunner::Configuration::Commands::CodegenListCommand then
        options[:command].list.each{ |value|
          CodegenPipeline.start(options.merge value)
        }
        FormatDirectoryPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        finalize
        return
      end
      finalize
    end
  end
end

module AnytypeSwiftCodegenRunner::Pipeline
  def self.start(options)
    CompoundPipeline.start(options)
  end
end

class Matrix
  class Configuration
    class << self
      def protobufDirectory
        "#{__dir__}/../Modules/ProtobufMessages/Sources/"
      end
      def commandsFilePath
        self.protobufDirectory + "commands.pb.swift"
      end
      def modelsFilePath
        self.protobufDirectory + "models.pb.swift"
      end
      def eventsFilePath
        self.protobufDirectory + "events.pb.swift"
      end
    end

    attr_accessor :transform, :filePath
    def initialize(transform, filePath)
      self.transform = transform
      self.filePath = filePath
    end
    def to_json(*args)
      "transform: #{transform} to file: #{filePath}"
    end

    def options
      {
        transform: transform,
        filePath: filePath,
      }
    end

    class << self
      def make_all
        [make_inits_for_commands, make_inits_for_models, make_inits_for_events, make_error_protocols_for_commands, make_services_for_commands]
      end
      def make_error_protocols_for_commands
        new("error_protocol", self.commandsFilePath)
      end
      def make_services_for_commands
        new("services", self.commandsFilePath)
      end
      def make_inits_for_commands
        new("inits", self.commandsFilePath)
      end
      def make_inits_for_models
        new("inits", self.modelsFilePath)
      end
      def make_inits_for_events
        new("inits", self.eventsFilePath)
      end
    end
  end
end

class MainWork
  class << self
    def work(arguments)
      work = new
      options = work.parse_options(arguments)
      work.work(options)
    end
  end

  # fixing arguments
  def fix_options(options)
    options
  end
  def required_keys
    [:toolPath]
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
      exit(0)
    end

    ShellExecutor.setup options[:dry_run]

    AnytypeSwiftCodegenRunner::Pipeline.start(options)
  end

  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        {
          # command
          command: AnytypeSwiftCodegenRunner::Configuration::Commands::CodegenListCommand.new(Matrix::Configuration.make_all.map(&:options)),
          # tool
          toolPath: "#{__dir__}/anytype_swift_codegen.rb",
          # output directory
          outputDirectory: Matrix::Configuration.protobufDirectory,
          # format tool
          formatToolPath: "#{__dir__}/swift_format.rb"
        }
      end

      def filePathOptions
        [:toolPath]
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

    This script will help you generate pb.swift convenient interfaces and services.

    It generates the following setup: #{JSON.pretty_generate(Matrix::Configuration.make_all)}

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
      opts.on('--toolPath', '--toolPath PATH', 'Path to anytype codegen script.') {|v| options[:toolPath] = v}
      opts.on('--filter', '--filter NAME', 'Generate only filtered files.') {|v| options[:filteredFile] = v}
      opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
      opts.on('-i', '--inspection', 'Inspection of all items, like tests'){|v| options[:inspection] = v}
      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}
    end.parse!(arguments)
    DefaultOptionsGenerator.populate(arguments, options)
  end
end

MainWork.work(ARGV)
