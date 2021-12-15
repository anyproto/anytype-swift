require_relative '../workers_hub'
require_relative '../library/shell_executor'

class ApplyTransformsWorker
  attr_accessor :tool, :options

  def initialize(tool, options)
    self.tool = tool
    self.options = options
  end

  def work
    result = []
    options.each {|k, v|
      result += ["--" + k.to_s, v]
    }
    action = "#{tool} generate #{result.join(" ")}"
    ShellExecutor.run_command_line action
  end

end