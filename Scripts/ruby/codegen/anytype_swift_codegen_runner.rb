require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../workers_hub'
require_relative '../pipeline_starter'
require_relative 'codegen_config'
require_relative 'codegen_commands'
require_relative 'codegen_pipelines'
require_relative 'codegen_runner_options'
require_relative 'codegen_runner_options_parser'

class MainWork
  def self.work(arguments)
    options = CodegenRunnerOptionsParser.parse_options(arguments)
    CompoundPipeline.start(options)
  end
end

MainWork.work(ARGV)
