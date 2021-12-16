require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'
require_relative 'codegen_options_gen'

class CodegenRunner
  def self.run
    CodegenConfig.make_all.each{ |value|
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

    Dir.entries(directory)
      .map{ |fileName|
        File.join(directory, fileName)
      }
      .select{ |file|
        File.file?(file) && File.extname(file) == '.swift'
      }.each{ |filePath|
        runSwiftFormat(filePath)
      }
  end

  private_class_method def self.runSwiftFormat(input_path)
      configuration_path = File.expand_path("#{__dir__}/../../../Tools/swift-format-configuration.json")
      tool = File.expand_path("#{__dir__}/../../../Tools/swift-format")

      action = "#{tool} -i --configuration #{configuration_path} #{input_path}"
      
      ShellExecutor.run_command_line action
    end
  end
