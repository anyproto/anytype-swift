require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'
require_relative 'codegen_options_gen'
require_relative 'codegen_configuration'

class CodegenRunner
  def self.run
    CodegenConfig.make_all.map(&:options).each{ |value|
      options = {}
      options[:command] = ApplyTransformsCommand.new(value[:transform])
      options[:transform] = value[:transform]
      options[:filePath] = value[:filePath]

      options = CodegenDefaultOptionsGenerator.populate(options)

      ApplyTransformsPipeline.start(options)
    }

    FormatDirectoryPipeline.start(File.expand_path(CodegenConfig::ProtobufDirectory))
  end
end
