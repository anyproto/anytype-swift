require_relative 'ruby/options'
require_relative 'ruby/pipeline_starter'

class Main
  def self.exec(arguments)
    options = Options.parsed(arguments)
    PipelineStarter.start(options)
  end
end

Main.exec(ARGV)
