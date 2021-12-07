require_relative 'ruby/workers_hub'
require_relative 'ruby/options/options_parser'
require_relative 'ruby/pipeline_starter'

class Main
  def self.exec(arguments)
    options = OptionsParser.parse_options(arguments)
    ShellExecutor.setup options[:dry_run]
    PipelineStarter.start(options)
  end
end

Main.exec(ARGV)