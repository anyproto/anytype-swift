require_relative '../core/valid_worker'
require_relative '../../constants'

class CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker < AlwaysValidWorker
    attr_accessor :temporaryDirectoryPath, :targetDirectoryPath

    def initialize(temporaryDirectoryPath, targetDirectoryPath)
      self.temporaryDirectoryPath = temporaryDirectoryPath
      self.targetDirectoryPath = targetDirectoryPath
    end

    def perform_work
      middlewareLibraryName = "Lib.xcframework"
      filenames = [middlewareLibraryName ,Constans.PROTOBUF_DIRECTORY_NAME]

      files = filenames.map { |x| File.join(temporaryDirectoryPath, x) }
      FileUtils.mv(files, targetDirectoryPath)
    end
  end