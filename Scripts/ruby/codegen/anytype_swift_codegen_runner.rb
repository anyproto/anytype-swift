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
    puts "Running codegen"
    codegenOptions().each { |options|
      options = CodegenDefaultOptionsGenerator.populate(options)
      puts "Running codegen #{options[:transform]} for file: #{options[:filePath]}"
      ApplyTransformsPipeline.start(options)
    }

    formatFiles()
  end

  private_class_method def self.formatFiles()
    puts "Running swift format"
    DirHelper.allFiles(CodegenConfig::ProtobufDirectory, "swift")
      .each { |path|
        puts "Running swift format for file #{path}"
        action = "#{CodegenConfig::SwiftFormatPath} -i --configuration #{CodegenConfig::SwiftFormatConfigPath} #{path}"
        ShellExecutor.run_command_line_silent action
     }
  end

  # names of transforms stored in https://github.com/anytypeio/anytype-swift-codegen
  private_class_method def self.codegenOptions()
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
