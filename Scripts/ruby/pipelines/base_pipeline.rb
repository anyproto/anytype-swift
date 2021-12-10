require 'tmpdir'
require_relative '../workers_hub'
require_relative '../constants'

class BasePipeline
  def self.work(version, options)
    puts "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token]).work
    puts "I have gathered information!"

    puts "Now lets find our url to release!"
    assetURL = GetRemoteAssetURLWorker.new(information, version).work
    puts "Our URL is: #{assetURL}"

    downloadFilePath = Constants::downloadFilePath
    puts "Start downloading library to #{downloadFilePath}"
    DownloadFileAtURLWorker.new(options[:token], assetURL, downloadFilePath).work
    puts "Library is downloaded at #{downloadFilePath}"

    temporaryDirectory = Dir.mktmpdir
    puts "Start uncompressing to directory #{temporaryDirectory}"
    UncompressFileToTemporaryDirectoryWorker.new(downloadFilePath, temporaryDirectory).work

    ourDirectory = Constants::dependenciesDirectoryPath
    puts "Cleaning up Dependencies directory #{ourDirectory}"
    CleanupDependenciesDirectoryWorker.new(ourDirectory).work

    puts "Moving files from temporaryDirectory #{temporaryDirectory} to ourDirectory: #{ourDirectory}"
    CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, ourDirectory).work

    puts "Cleaning up Downloaded files"
    RemoveDirectoryWorker.new(downloadFilePath).work
    RemoveDirectoryWorker.new(temporaryDirectory).work

    if options[:runsOnCI] == false
      puts "Moving protobuf files from Dependencies to our project directory"
      CopyProtobufFilesWorker.new(ourDirectory).work

      puts "Generate services from protobuf files"
      codegen_runner = File.expand_path("#{__dir__}../codegen/anytype_swift_codegen_runner.rb")
      "ruby #{codegen_runner}"
    end
  end
end