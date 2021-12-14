require 'yaml'

require_relative '../core/valid_worker'
require_relative '../../constants'

class GetLockfileVersionWorker < AlwaysValidWorker
  attr_accessor :filePath

  def initialize(filePath)
    self.filePath = filePath
  end

  def perform_work
    (YAML.load File.open(filePath))[Constants::LOCKFILE_VERSION_KEY]
  end
end