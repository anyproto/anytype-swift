require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative 'codegen_workers'
require_relative 'codegen_configuration'
require_relative 'codegen_pipelines'
require_relative 'codegen_options_gen'
require_relative 'codegen_options_parser'
 
class Main
  def self.work(arguments)
    options = CodegenOptionsParser.parse_options(arguments)
    ApplyTransformsPipeline.start(options)
  end
end

Main.work(ARGV)
