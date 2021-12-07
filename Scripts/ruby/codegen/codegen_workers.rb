require_relative '../workers_hub'

class BuilderWorker < ExternalToolWorker
  def tool
    "swift"
  end
  def action
    "#{tool} build"
  end
end
class ToolVersionWorker < ExternalToolWorker
  def action
    "#{tool} version"
  end
end
class ListTransformsWorker < ExternalToolWorker
  def action
    "#{tool} generate -l"
  end
end
class ToolHelpWorker < ExternalToolWorker
  def action
    "#{tool} help"
  end
end
class ApplyTransformsWorker < ExternalToolWorker
  attr_accessor :options
  def initialize(toolPath, options)
    super(toolPath)
    self.options = options
  end
  def action
    result = []
    options.each {|k, v|
      result += ["--" + k.to_s, v]
    }
    "#{tool} generate #{result.join(" ")}"
  end
end