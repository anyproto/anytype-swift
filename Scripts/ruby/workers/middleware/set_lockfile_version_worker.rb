require_relative '../core/valid_worker'
require_relative '../../constants'

class SetLockfileVersionWorker < AlwaysValidWorker
  attr_accessor :value
  
  def initialize(filePath, value)
    self.value = value
  end

  def perform_work
    filePath = Constants::librarylockFilePath
    result = { Constants::LOCKFILE_VERSION_KEY => value}.to_yaml
    result = result.gsub(/^---\s+/, '')
    File.open(filePath, 'w') do |file_handler|
      file_handler.write(result)
    end
  end
end