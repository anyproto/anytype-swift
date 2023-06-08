class CleanupDependenciesDirectoryWorker
  attr_accessor :directoryPath
  def initialize(directoryPath)
    self.directoryPath = directoryPath
  end

  def work
    FileUtils.rm_rf directoryPath
  end
end