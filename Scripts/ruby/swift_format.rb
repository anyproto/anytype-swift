require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative 'library/shell_executor'
require_relative 'workers_hub'
require_relative 'pipeline_starter'

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
  class FormatPipeline
    def self.start(options)
      SwiftFormat::FormatWorker.new(options[:toolPath], options[:configurationFilePath], options[:inputFilePath]).work
    end
  end
end

module SwiftFormat::Pipeline
  class CompoundPipeline
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

class SwiftFormatRunner
  def self.run(inputFilePath)
    defaultOptions = {
      command: SwiftFormat::Configuration::Commands::FormatCommand.new,
      configurationFilePath: File.expand_path("#{__dir__}/../../Tools/swift-format-configuration.json"),
      toolPath: File.expand_path("#{__dir__}/../../Tools/swift-format")
    }

    options = {}
    options[:inputFilePath] = inputFilePath
    options = defaultOptions.merge options
    SwiftFormat::Pipeline.start(options)
  end
end