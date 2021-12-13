require_relative '../../constants'

class CopyProtobufFilesWorker
  attr_accessor :dependenciesDirectoryPath
  def initialize(dependenciesDirectoryPath)
    self.dependenciesDirectoryPath = dependenciesDirectoryPath
  end

  def protobuf_files
    [
      "commands.pb.swift",
      "events.pb.swift",
      "models.pb.swift",
      "localstore.pb.swift"
    ]
  end

  def work
    directory = File.join([self.dependenciesDirectoryPath, Constants::PROTOBUF_DIRECTORY_NAME])
    files = protobuf_files.map{|v| File.join([directory, v])}
    target_directory = Constants::TARGET_DIR_PATH
    FileUtils.mv(files, target_directory)
  end
end