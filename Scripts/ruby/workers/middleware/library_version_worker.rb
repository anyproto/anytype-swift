require_relative '../core/valid_worker'
require_relative '../../library/semantic_versioning'
require_relative '../../constants'

class GetLibraryfileVersionWorker < AlwaysValidWorker
  def perform_work
    filePath = Constants::libraryFilePath
    value = (YAML.load File.open(filePath))[Constants::LOCKFILE_VERSION_KEY]
    SemanticVersioning::Parsers::Parser.parse(value)
  end
end