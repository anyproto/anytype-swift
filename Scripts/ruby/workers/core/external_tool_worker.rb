require_relative 'base_worker'

class ExternalToolWorker < BaseWorker
  attr_accessor :toolPath
  def initialize(toolPath)
    self.toolPath = toolPath
  end
  def is_valid?
    File.exists? toolPath
  end
  def tool
    "#{toolPath}"
  end
end