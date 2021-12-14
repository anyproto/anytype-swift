require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../workers_hub'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'

class MainWork
  def self.work(arguments)
    options = {
        list: CodegenConfig.make_all.map(&:options),
        toolPath: File.expand_path("#{__dir__}/anytype_swift_codegen.rb"),
        outputDirectory: File.expand_path(CodegenConfig::ProtobufDirectory),
        formatToolPath: File.expand_path("#{__dir__}/swift_format.rb")
    }

    options[:list].each{ |value|
      CodegenPipeline.start(options[:toolPath], value[:transform], value[:filePath])
    }
    FormatDirectoryPipeline.start(options)
  end
end

MainWork.work(ARGV)
