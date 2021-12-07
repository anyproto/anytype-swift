require_relative '../core/base_worker'


class UncompressFileToTemporaryDirectoryWorker < BaseWorker
  attr_accessor :filePath, :temporaryDirectory
  def initialize(filePath, temporaryDirectory)
    self.filePath = filePath
    self.temporaryDirectory = temporaryDirectory
  end
  def tool
    "tar"
  end
  def action
    "#{tool} -zxf #{filePath} -C #{temporaryDirectory}"
  end
end
