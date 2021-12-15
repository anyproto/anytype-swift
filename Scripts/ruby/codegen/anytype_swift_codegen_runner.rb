require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'
require_relative 'anytype_swift_codegen'

class CodegenRunner
  def self.run
    options = {
        toolPath: File.expand_path("#{__dir__}/anytype_swift_codegen.rb"),
        outputDirectory: File.expand_path(CodegenConfig::ProtobufDirectory)
    }

    CodegenConfig.make_all.map(&:options).each{ |value|
      transform = value[:transform]
      filePath = value[:filePath]
      Codegen.run(transform, filePath)
    }

    FormatDirectoryPipeline.start(options)
  end
end
