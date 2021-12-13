class RemoveDirectoryWorker
  attr_accessor :directoryPath
  def initialize(directoryPath)
    self.directoryPath = directoryPath
  end

  def work
    FileUtils.remove_entry directoryPath
  end
end