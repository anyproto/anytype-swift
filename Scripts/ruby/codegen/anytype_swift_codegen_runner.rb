require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../library/dir_helper'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'
require_relative 'codegen_options_gen'

class CodegenRunner
  def self.run
    codegenFiles().each{ |value|
      options = {}
      options[:transform] = value[:transform]
      options[:filePath] = value[:filePath]

      options = CodegenDefaultOptionsGenerator.populate(options)

      ApplyTransformsPipeline.start(options)
    }

    runFortatting()
  end

  private_class_method def self.runFortatting()
    directory = CodegenConfig::ProtobufDirectory
    files = DirHelper.allFiles(CodegenConfig::ProtobufDirectory, "swift")
    files.each{ |path| runSwiftFormat(path) }
  end

  private_class_method def self.runSwiftFormat(input_path)
      configuration_path = File.expand_path("#{__dir__}/../../../Tools/swift-format-configuration.json")
      swift_format = File.expand_path("#{__dir__}/../../../Tools/swift-format")

      action = "#{swift_format} -i --configuration #{configuration_path} #{input_path}"
      
      ShellExecutor.run_command_line action
  end

  def self.codegenFiles()
    [
      { transform: "memberwiseInitializer", filePath: CodegenConfig::ModelsFilePath }, 
      { transform: "memberwiseInitializer", filePath: CodegenConfig::EventsFilePath },
      { transform: "memberwiseInitializer", filePath: CodegenConfig::LocalstoreFilePath },

      { transform: "memberwiseInitializer", filePath: CodegenConfig::CommandsFilePath },
      { transform: "errorAdoption", filePath: CodegenConfig::CommandsFilePath }, 
      { transform: "serviceWithRequestAndResponse", filePath: CodegenConfig::CommandsFilePath }
    ]
  end
end
