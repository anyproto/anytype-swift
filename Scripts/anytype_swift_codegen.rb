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

module AnytypeSwiftCodegen
  TravelerWorker = Workers::TravelerWorker
  class BaseWorker < Workers::BasicWorker
    class << self
      def repository_based_tool
        "swift run anytype-swift-codegen"
      end
    end
    attr_accessor :toolPath
    def initialize(toolPath = nil)
      self.toolPath = toolPath || self.class.repository_based_tool
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
  class BuilderWorker < BaseWorker
    def tool
      "swift"
    end
    def action
      "#{tool} build"
    end
  end
  class ToolVersionWorker < BaseWorker
    def action
      "#{tool} version"
    end
  end
  class ListTransformsWorker < BaseWorker
    def action
      "#{tool} generate -l"
    end
  end
  class ToolHelpWorker < BaseWorker
    def action
      "#{tool} help"
    end
  end
  class ApplyTransformsWorker < BaseWorker
    attr_accessor :options
    def initialize(toolPath, options)
      super(toolPath)
      self.options = options
    end
    def action
      result = []
      options.each {|k, v|
        result += ["--" + k.to_s, v]
      }
      "#{tool} generate #{result.join(" ")}"
    end
  end
end

module AnytypeSwiftCodegen
  module Configuration
    module Commands
      class BaseCommand
        def to_json(*args)
          self.class.name
        end
      end
      class ToolVersionCommand < BaseCommand
      end
      class ToolHelpCommand < BaseCommand
      end
      class ListTransformsCommand < BaseCommand
      end
      class ApplyTransformsCommand < BaseCommand
        attr_accessor :transform
        def initialize(transform)
          self.transform = transform
        end
        def to_s
          "#{self.class.name} our_transform: #{self.our_transform} and tool_transform: #{self.tool_transform}"
        end
        def to_json(*args)
          self.to_s
        end
        def inspect
          self.to_s
        end
      end
    end
    module EnvironmentVariables
    end
  end
end

# transforms of transform
class AnytypeSwiftCodegen::Configuration::Commands::ApplyTransformsCommand
  module SwiftCodegenCLIOptions
    module GenerateOptions
      AVAILABLE_VARIANTS = [
        ErrorAdoption = 'e',
        RequestAndResponse = 'rr',
        MemberwiseInitializer = 'mwi',
        ServiceWithRequestAndResponse = 'swrr',
      ]
    end
  end
  # Our representation of swift-codegen utility options
  module CodegenCLIScopes
    AVAILABLE_VARIANTS = [
      Initializers = 'inits',
      Services = 'services',
      ErrorProtocol = 'error_protocol'
    ]
    def self.swift_codegen_option(scope)
      case scope
      when ErrorProtocol then SwiftCodegenCLIOptions::GenerateOptions::ErrorAdoption
      when Initializers then SwiftCodegenCLIOptions::GenerateOptions::MemberwiseInitializer
      when Services then SwiftCodegenCLIOptions::GenerateOptions::ServiceWithRequestAndResponse
      end
    end
    def self.codegen_option_from_swift(option)
      case option
      when SwiftCodegenCLIOptions::GenerateOptions::ErrorAdoption then ErrorProtocol
      when SwiftCodegenCLIOptions::GenerateOptions::MemberwiseInitializer then Initializers
      when SwiftCodegenCLIOptions::GenerateOptions::ServiceWithRequestAndResponse then Services
      end
    end
    def self.suffix(scope, key)
      case scope
        when Initializers then
          case key
            when :outputFilePath then "+Initializers"
            when :templateFilePath then nil #"+Initializers+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Initializers+Import"
          end
        when Services then
          case key
            when :outputFilePath then "+Service"
            when :templateFilePath then "+Service+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Service+Import"
          end
        when ErrorProtocol then
          case key
            when :outputFilePath then "+ErrorAdoption"
            when :templateFilePath then nil
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then nil
          end
      end
    end
  end

  def our_transform
    self.transform
  end
  def tool_transform
    CodegenCLIScopes.swift_codegen_option(self.our_transform)
  end
  def suffix_for_file(key)
    CodegenCLIScopes.suffix(self.our_transform, key)
  end
  def self.available_transforms
    CodegenCLIScopes::AVAILABLE_VARIANTS
  end
end

module AnytypeSwiftCodegen
  module Pipeline
    BasePipeline = Pipelines::BasePipeline
  end
end

module AnytypeSwiftCodegen::Pipeline
  class ToolVersionPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
      end
      say "Look at current version!"
      puts AnytypeSwiftCodegen::ToolVersionWorker.new(options[:toolPath]).work
    end
  end
end

module AnytypeSwiftCodegen::Pipeline
  class ToolHelpPipeline < BasePipeline
    def self.start(options)
      say "Look at help meesage from tool!"
      puts AnytypeSwiftCodegen::ToolHelpWorker.new(options[:toolPath]).work
    end
  end
end

module AnytypeSwiftCodegen::Pipeline
  class ListTransformsPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
      end
      say "Look at available trasnforms!"
      puts AnytypeSwiftCodegen::ListTransformsWorker.new(options[:toolPath]).work
    end
  end
end

module AnytypeSwiftCodegen::Pipeline
  class ApplyTransformsPipeline < BasePipeline
    def self.start(options)
      if Dir.exists? options[:toolPath]
        AnytypeSwiftCodegen::TravelerWorker.new(options[:toolPath]).work
      end

      extracted_options_keys = [:filePath, :transform, :outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath, :serviceFilePath]

      sliced_options = {}
      extracted_options_keys.each {|k|
        value = options[k]
        unless value.nil?
          sliced_options[k] = value
        end
      }

      say "You want to generate something?"
      puts "sliced_options are: #{sliced_options}"
      say "Lets go!"

      AnytypeSwiftCodegen::ApplyTransformsWorker.new(options[:toolPath], sliced_options).work
      say "Congratulations! You have just generated new protobuf files!"
    end
  end
end

module AnytypeSwiftCodegen::Pipeline
  class CompoundPipeline < BasePipeline
    def self.start(options)
      say "Lets find your command in a list..."
      case options[:command]
      when AnytypeSwiftCodegen::Configuration::Commands::ToolVersionCommand then ToolVersionPipeline.start(options)
      when AnytypeSwiftCodegen::Configuration::Commands::ToolHelpCommand then ToolHelpPipeline.start(options)
      when AnytypeSwiftCodegen::Configuration::Commands::ListTransformsCommand then ListTransformsPipeline.start(options)
      when AnytypeSwiftCodegen::Configuration::Commands::ApplyTransformsCommand then ApplyTransformsPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        finalize
        return
      end
      finalize
    end
  end
end

module AnytypeSwiftCodegen::Pipeline
  def self.start(options)
    CompoundPipeline.start(options)
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
    [:toolPath, :filePath] # but not by all options.
  end
  def valid_options?(options)
    # true
    case options[:command]
    when AnytypeSwiftCodegen::Configuration::Commands::ToolVersionCommand then true
    when AnytypeSwiftCodegen::Configuration::Commands::ToolHelpCommand then true
    when AnytypeSwiftCodegen::Configuration::Commands::ListTransformsCommand then true
    else
      (required_keys - options.keys).empty?
    end
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

    AnytypeSwiftCodegen::Pipeline.start(options)
  end

  # OutputFilePath <- f (filePath, transform)
  # CommentsHeaderFilePath <- f (filePath)
  # ImportsFilePath <- f (filePath, transform)
  # TemplateFilePath <- f(filePath, transform) # only for specific transforms.
  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        options = {
          # commands
          command: AnytypeSwiftCodegen::Configuration::Commands::ToolHelpCommand,
          # tools
          toolPath: "#{__dir__}/../Tools/anytype-swift-codegen",
          # templates
          templatesDirectoryPath: "#{__dir__}/../Templates/Middleware",
          # comments header
          commentsHeaderFilePath: "#{__dir__}/../Templates/Middleware/commands+HeaderComments.pb.swift",
          # service file path
          serviceFilePath: "#{__dir__}/../Dependencies/Middleware/protobuf/protos/service.proto",
        }
      end
      def available_transforms
        AnytypeSwiftCodegen::Configuration::Commands::ApplyTransformsCommand.available_transforms
      end

      def appended_suffix(suffix, inputFilePath, directoryPath)
        unless inputFilePath.nil?
          unless suffix.nil?
            pathname = Pathname.new(inputFilePath)
            basename = pathname.basename
            components = basename.to_s.split(".")
            the_name = components.first
            the_extname = components.drop(1).join(".")
            result_name = directoryPath + "/" + the_name + suffix + ".#{the_extname}"
            result_name
          end
        end
      end

      def generateFilePaths(options)
        if options[:command].is_a? AnytypeSwiftCodegen::Configuration::Commands::ApplyTransformsCommand
          command = options[:command]
          unless command.tool_transform.nil?
            our_transform = command.our_transform
            tool_transform = command.tool_transform
            result = {
              transform: tool_transform,
              filePath: options[:filePath],
            }
            keys = [:outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath]
            for k in keys
              directoryPath = k == :outputFilePath ? Pathname.new(options[:filePath]).dirname.to_s : options[:templatesDirectoryPath]
              value = self.appended_suffix(command.suffix_for_file(k), options[:filePath], directoryPath)
              unless value.nil?
                result[k] = value
              end
            end
            result
          end
        end
      end

      def filePathOptions
        [
          :toolPath,
          :filePath,
          :outputFilePath,
          :templateFilePath,
          :commentsHeaderFilePath,
          :importsFilePath,
          :serviceFilePath
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
        result = defaultOptions.merge options
        result = generateFilePaths(result).merge result
        fixOptions(result)
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

    First, it takes arguments:
    [required] <--filePath PATH> Path to a file which will be used to generate desired services and interfaces.
    Other options you can inspect via
    ruby #{$0} --help

    ---------------
    Usage:
    ---------------
    # or if you want Siri Voice, set environment variable SIRI_VOICE=1
    SIRI_VOICE=1 ruby #{$0} <parameters>

    DefaultConfiguration: #{JSON.pretty_generate(DefaultOptionsGenerator.defaultOptions)}

    1. Parameters
    ruby #{$0} --transform inits --filePath <PATH> [other parameters].

    Available actions e.g. transforms: [#{DefaultOptionsGenerator.available_transforms}]


    __HELP__
  end

  def parse_options(arguments)
    # we could also add names for commands to separate them.
    # thus, we could add 'generate init' and 'generate services'
    # add dispatch for first words.
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"

      opts.on('-v', '--version', 'Version of tool') {|v| options[:command] = AnytypeSwiftCodegen::Configuration::Commands::ToolVersionCommand.new}
      opts.on('--toolHelp', '--toolHelp', 'Print tool help message') {|v| options[:command] = AnytypeSwiftCodegen::Configuration::Commands::ToolHelpCommand.new}
      opts.on('-l', '--list_transforms', 'List available transforms') {|v| options[:command] = AnytypeSwiftCodegen::Configuration::Commands::ListTransformsCommand.new}
      opts.on('-t', '--transform TRANSFORM', 'Which transform we would like to apply') {|v| options[:command] = AnytypeSwiftCodegen::Configuration::Commands::ApplyTransformsCommand.new(v)}

      # # tool option
      opts.on('--cli', '--toolPath PATH', 'Path to directory with anytype-swift-codegen') {|v| options[:toolPath] = v}

      # # file options
      opts.on('-f', '--filePath PATH', 'Input file with generated swift protobuf models') {|v| options[:filePath] = v}
      opts.on('--outputFilePath', '--outputFilePath PATH', 'Output to file') {|v| options[:outputFilePath] = v}
      opts.on('--templateFilePath', '--templateFilePath PATH', 'File with templates which are used in some transforms'){|v| options[:templateFilePath] = v}
      opts.on('--commentsHeaderFilePath', '--commentsHeaderFilePath PATH', 'Header at the top of file'){|v| options[:commentsHeaderFilePath] = v}
      opts.on('--importsFilePath', '--importsFilePath PATH', 'Import statements at the top of file'){|v| options[:importsFilePath] = v}

      opts.on('--templatesDirectoryPath', '--templatesDirectoryPath PATH', 'Templates directory path'){|v| options[:templatesDirectoryPath] = v}
      opts.on('--serviceFilePath', '--serviceFilePath PATH', 'Rpc service file that contains Rpc services descriptions in .proto (protobuffers) format.') {|v| options[:serviceFilePath] = v}

      opts.on('-d', '--dry_run', 'Dry run to see all options') {|v| options[:dry_run] = v}
      opts.on('-i', '--inspection', 'Inspection of all items, like tests'){|v| options[:inspection] = v}
      # help
      opts.on('-h', '--help', 'Help option') { self.help_message(opts); exit(0)}
    end.parse!(arguments)
    DefaultOptionsGenerator.populate(arguments, options)
  end
end

MainWork.work(ARGV)
