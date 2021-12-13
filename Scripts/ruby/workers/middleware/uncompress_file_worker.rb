require_relative '../../library/shell_executor'


class UncompressFileToTemporaryDirectoryWorker
  attr_accessor :filePath, :temporaryDirectory
  
  def initialize(filePath, temporaryDirectory)
    self.filePath = filePath
    self.temporaryDirectory = temporaryDirectory
  end

  def work
    action = "tar -zxf #{filePath} -C #{temporaryDirectory}"
    ShellExecutor.run_command_line action
  end
end
