require_relative 'core/valid_worker'

class CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker < AlwaysValidWorker
    attr_accessor :temporaryDirectoryPath, :filesNames, :targetDirectoryPath
    def initialize(temporaryDirectoryPath, filesNames = [], targetDirectoryPath)
      self.temporaryDirectoryPath = temporaryDirectoryPath
      self.filesNames = filesNames
      self.targetDirectoryPath = targetDirectoryPath
    end
    def perform_work
      if filesNames.empty?
        puts "filesNames are empty!"
        return
      end
      files = filesNames.map{|x| File.join(temporaryDirectoryPath, x)}
      FileUtils.mv(files, targetDirectoryPath)
    end
  end