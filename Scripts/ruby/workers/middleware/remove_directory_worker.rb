require_relative '../core/valid_worker'

class RemoveDirectoryWorker < AlwaysValidWorker
  attr_accessor :directoryPath
  def initialize(directoryPath)
    self.directoryPath = directoryPath
  end
  def perform_work
    FileUtils.remove_entry directoryPath
  end
end