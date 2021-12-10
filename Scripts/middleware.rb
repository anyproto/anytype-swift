require_relative 'ruby/workers_hub'
require_relative 'ruby/options'
require_relative 'ruby/pipeline_starter'

class Main
  def self.exec(arguments)
    options = OptionsParser.parse_options(arguments)
    PipelineStarter.start(options)
  end
end

Main.exec(ARGV)