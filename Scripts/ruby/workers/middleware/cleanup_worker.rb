require_relative '../core/valid_worker'

class CleanupDependenciesDirectoryWorker < AlwaysValidWorker
  attr_accessor :directoryPath
  def initialize(directoryPath)
    self.directoryPath = directoryPath
  end
  def perform_work
    FileUtils.remove_entry directoryPath
    FileUtils.mkdir_p directoryPath
  end
end