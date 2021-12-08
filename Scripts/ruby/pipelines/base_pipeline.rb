require 'tmpdir'
require_relative '../workers_hub'

class BasePipeline
  def self.work(version, options)
    puts "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token]).work
    puts "I have gathered information!"

    puts "Now lets find our url to release!"
    assetURL = GetRemoteAssetURLWorker.new(information, version).work
    puts "Our URL is: #{assetURL}"

    downloadFilePath = options[:downloadFilePath]
    puts "Start downloading library to #{downloadFilePath}"
    DownloadFileAtURLWorker.new(options[:token], assetURL, options[:downloadFilePath]).work
    puts "Library is downloaded at #{downloadFilePath}"

    temporaryDirectory = Dir.mktmpdir
    puts "Start uncompressing to directory #{temporaryDirectory}"
    UncompressFileToTemporaryDirectoryWorker.new(downloadFilePath, temporaryDirectory).work

    ourDirectory = options[:dependenciesDirectoryPath]
    puts "Cleaning up Dependencies directory #{ourDirectory}"
    CleanupDependenciesDirectoryWorker.new(ourDirectory).work

    puts "Moving files from temporaryDirectory #{temporaryDirectory} to ourDirectory: #{ourDirectory}"
    CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, ourDirectory).work

    puts "Cleaning up Downloaded files"
    RemoveDirectoryWorker.new(downloadFilePath).work
    RemoveDirectoryWorker.new(temporaryDirectory).work

    puts "Moving protobuf files from Dependencies to our project directory"
    CopyProtobufFilesWorker.new(ourDirectory, options[:targetDirectoryPath]).work

    puts "Generate services from protobuf files"
    RunCodegenScriptWorker.new(options[:swiftAutocodegenScript]).work
  end
end