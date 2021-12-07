require_relative 'core/base_worker'

class RunCodegenScriptWorker < BaseWorker
  attr_accessor :scriptPath
  def initialize(scriptPath)
    self.scriptPath = scriptPath
  end
  def tool
    "ruby"
  end
  def action
    "#{tool} #{scriptPath}"
  end
end