require_relative '../workers_hub'
require_relative '../library/shell_executor'

class ApplyTransformsWorker
  attr_accessor :options

  def initialize(options)
    self.options = options
  end

  def work
    tool = File.expand_path("#{__dir__}/../../../Tools/anytype-swift-codegen")
    result = []
    options.each {|k, v|
      result += ["--" + k.to_s, v]
    }
    action = "#{tool} generate #{result.join(" ")}"
    ShellExecutor.run_command_line action
  end

end