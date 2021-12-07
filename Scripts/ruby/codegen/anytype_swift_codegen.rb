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
    exec(options)
  end

  def self.required_keys
    [:toolPath, :filePath] # but not by all options.
  end
  def self.valid_options?(options)
    # true
    case options[:command]
    when ToolVersionCommand then true
    when ToolHelpCommand then true
    when ListTransformsCommand then true
    else
      (required_keys - options.keys).empty?
    end
  end

  def self.exec(options = {})
    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(1)
    end

    ShellExecutor.setup options[:dry_run]

    AnytypeSwiftCodegenPipeline.start(options)
  end
end

Main.work(ARGV)
