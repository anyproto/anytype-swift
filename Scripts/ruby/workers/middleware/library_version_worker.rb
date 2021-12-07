require_relative '../core/valid_worker'
require_relative '../../library/semantic_versioning'

class GetLibraryfileVersionWorker < AlwaysValidWorker
  attr_accessor :filePath, :key
  def initialize(filePath, key)
    self.filePath = filePath
    self.key = key
  end
  def perform_work
    value = (YAML.load File.open(filePath))[key]
    SemanticVersioning::Parsers::Parser.parse(value)
  end
end