class CodegenWorker
  attr_accessor :tool,:transform, :filePath
  def initialize(tool, transform, filePath)
    self.tool = tool
    self.transform = transform
    self.filePath = filePath
  end

  def work
    action = "ruby #{tool} --transform #{transform} --filePath #{filePath}"
    ShellExecutor.run_command_line action
  end
end

class FormatWorker
  attr_accessor :tool, :filePath
  def initialize(tool, filePath)
    self.tool = tool
    self.filePath = filePath
  end

  def work
    action = "ruby #{tool} --inputFilePath #{filePath}"
    ShellExecutor.run_command_line action
  end
end