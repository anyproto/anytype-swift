require_relative '../core/valid_worker'

class CopyProtobufFilesWorker < AlwaysValidWorker
  attr_accessor :dependenciesDirectoryPath, :protobufDirectoryName, :targetDirectoryPath
  def initialize(dependenciesDirectoryPath, protobufDirectoryName, targetDirectoryPath)
    self.dependenciesDirectoryPath = dependenciesDirectoryPath
    self.protobufDirectoryName = protobufDirectoryName
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
    directory = File.join([self.dependenciesDirectoryPath, self.protobufDirectoryName])
    files = protobuf_files.map{|v| File.join([directory, v])}
    target_directory = self.targetDirectoryPath
    FileUtils.mv(files, target_directory)
  end
end