require 'yaml'

require_relative '../library/semantic_versioning'
require_relative '../constants'

class GetLibraryfileVersionWorker
  def work
    filePath = Constants::LIBRARY_FILE_PATH
    value = (YAML.load File.open(filePath))[Constants::LOCKFILE_VERSION_KEY]
    SemanticVersioning::Parsers::Parser.parse(value)
  end
end