require 'yaml'

require_relative '../core/valid_worker'

class GetLockfileVersionWorker < AlwaysValidWorker
  attr_accessor :filePath, :key
  def initialize(filePath, key)
    self.key = key
    self.filePath = filePath
  end
  def perform_work
    (YAML.load File.open(filePath))[key]
  end
end