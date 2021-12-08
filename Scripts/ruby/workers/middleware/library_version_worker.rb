require_relative '../core/valid_worker'
require_relative '../../library/semantic_versioning'
require_relative '../../constants'

class GetLibraryfileVersionWorker < AlwaysValidWorker
  attr_accessor :filePath
  
  def initialize(filePath)
    self.filePath = filePath
  end

  def perform_work
    value = (YAML.load File.open(filePath))[Constants::LOCKFILE_VERSION_KEY]
    SemanticVersioning::Parsers::Parser.parse(value)
  end
end