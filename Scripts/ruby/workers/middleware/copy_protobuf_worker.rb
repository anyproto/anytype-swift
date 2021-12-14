require_relative '../core/valid_worker'
require_relative '../../constants'

class CopyProtobufFilesWorker < AlwaysValidWorker
  attr_accessor :dependenciesDirectoryPath, :targetDirectoryPath
  def initialize(dependenciesDirectoryPath, targetDirectoryPath)
    self.dependenciesDirectoryPath = dependenciesDirectoryPath
    self.targetDirectoryPath = targetDirectoryPath
  end
  def protobuf_files
    [
      "commands.pb.swift",
      "events.pb.swift",
      "models.pb.swift",
      "localstore.pb.swift"
    ]
  end
  def perform_work
    directory = File.join([self.dependenciesDirectoryPath, Constants::PROTOBUF_DIRECTORY_NAME])
    files = protobuf_files.map{|v| File.join([directory, v])}
    target_directory = self.targetDirectoryPath
    FileUtils.mv(files, target_directory)
  end
end