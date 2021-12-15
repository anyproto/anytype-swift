require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_pipelines'

class CodegenRunner
  def self.run
    options = {
        toolPath: File.expand_path("#{__dir__}/anytype_swift_codegen.rb"),
        outputDirectory: File.expand_path(CodegenConfig::ProtobufDirectory),
        formatToolPath: File.expand_path("#{__dir__}/../../swift_format.rb")
    }

    CodegenConfig.make_all.map(&:options).each{ |value|
      tool = options[:toolPath]
      transform = value[:transform]
      filePath = value[:filePath]
      ShellExecutor.run_command_line "ruby #{tool} --transform #{transform} --filePath #{filePath}"
    }

    FormatDirectoryPipeline.start(options)
  end
end
