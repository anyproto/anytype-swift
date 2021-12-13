class CleanupDependenciesDirectoryWorker
  attr_accessor :directoryPath
  def initialize(directoryPath)
    self.directoryPath = directoryPath
  end

  def work
    FileUtils.remove_entry directoryPath
    FileUtils.mkdir_p directoryPath
  end
end