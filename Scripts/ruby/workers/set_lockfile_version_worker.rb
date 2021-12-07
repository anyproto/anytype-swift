require_relative 'core/valid_worker'

class SetLockfileVersionWorker < AlwaysValidWorker
  attr_accessor :filePath, :key, :value
  def initialize(filePath, key, value)
    self.filePath = filePath
    self.key = key
    self.value = value
  end
  def perform_work
    result = {key => value}.to_yaml
    result = result.gsub(/^---\s+/, '')
    File.open(filePath, 'w') do |file_handler|
      file_handler.write(result)
    end
  end
end