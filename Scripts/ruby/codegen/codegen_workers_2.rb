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