require 'optparse'
require 'shellwords'
require 'pathname'
require 'json'

require_relative '../library/shell_executor'
require_relative '../workers_hub'
require_relative '../pipeline_starter'
require_relative 'codegen_matrix'
require_relative 'codegen_commands'
require_relative 'codegen_pipelines'

class MainWork
  class << self
    def work(arguments)
      work = new
      options = work.parse_options(arguments)
      work.work(options)
    end
  end

  # fixing arguments
  def fix_options(options)
    options
  end
  def required_keys
    [:toolPath]
  end
  def valid_options?(options)
    # true
    (required_keys - options.keys).empty?
  end

  def work(options = {})
    options = fix_options(options)

    unless valid_options? options
      puts "options are not valid!"
      puts "options are: #{options}"
      puts "missing options: #{required_keys}"
      exit(1)
    end

    CompoundPipeline.start(options)
  end

  class DefaultOptionsGenerator
    class << self
      def defaultOptions
        {
          # command
          command: CodegenListCommand.new(Matrix::Configuration.make_all.map(&:options)),
          # tool
          toolPath: "#{__dir__}/anytype_swift_codegen.rb",
          # output directory
          outputDirectory: Matrix::Configuration.protobufDirectory,
          # format tool
          formatToolPath: "#{__dir__}/swift_format.rb"
        }
      end

      def filePathOptions
        [:toolPath, :outputDirectory, :formatToolPath]
      end

      def fixOptions(options)
        result_options = options
        filePathOptions.each do |v|
          unless result_options[v].nil?
            result_options[v] = File.expand_path(result_options[v])
          end
        end
        result_options
      end

      def generate(arguments, options)
        result_options = defaultOptions.merge options
        fixOptions(result_options)
      end

      def populate(arguments, options)
        new_options = self.generate(arguments, options)
        new_options = new_options.merge(options)
        fixOptions(new_options)
      end
    end
  end

  def help_message(options)
    puts <<-__HELP__

    #{options.help}

    This script will help you generate pb.swift convenient interfaces and services.

    It generates the following setup: #{JSON.pretty_generate(Matrix::Configuration.make_all)}

    DefaultConfiguration: #{JSON.pretty_generate(DefaultOptionsGenerator.defaultOptions)}

    __HELP__
  end

  def parse_options(arguments)
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"
      opts.on('--toolPath', '--toolPath PATH', 'Path to anytype codegen script.') {|v| options[:toolPath] = v}
      opts.on('-h', '--help', 'Help') { self.help_message(opts); exit(0)}
    end.parse!(arguments)

    DefaultOptionsGenerator.populate(arguments, options)
  end
end

MainWork.work(ARGV)
