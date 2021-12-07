require_relative 'ruby/middleware_updater'
require_relative 'ruby/options/options_parser'
require_relative 'ruby/pipeline_starter'

class Main
  def self.exec(arguments)
    options = OptionsParser.new.parse_options(arguments)
    ShellExecutor.setup options[:dry_run]
    PipelineStarter.start(options)
  end
end

Main.exec(ARGV)