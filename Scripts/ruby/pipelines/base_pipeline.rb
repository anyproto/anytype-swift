class BasePipeline
  def self.work(version, options)
    puts "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    puts "I have gathered information!"

    puts "Now lets find our url to release!"
    assetURL = GetRemoteAssetURLWorker.new(information, version, options[:iOSAssetMiddlewarePrefix]).work
    puts "Our URL is: #{assetURL}"

    downloadFilePath = options[:downloadFilePath]
    puts "Start downloading library to #{downloadFilePath}"
    DownloadFileAtURLWorker.new(options[:token], assetURL, options[:downloadFilePath]).work
    puts "Library is downloaded at #{downloadFilePath}"

    temporaryDirectory = MiddlewareUpdater::GetTemporaryDirectoryWorker.new.work
    puts "Start uncompressing to directory #{temporaryDirectory}"
    MiddlewareUpdater::UncompressFileToTemporaryDirectoryWorker.new(downloadFilePath, temporaryDirectory).work

    ourDirectory = options[:dependenciesDirectoryPath]
    puts "Cleaning up Dependencies directory #{ourDirectory}"
    MiddlewareUpdater::CleanupDependenciesDirectoryWorker.new(ourDirectory).work

    puts "Moving files from temporaryDirectory #{temporaryDirectory} to ourDirectory: #{ourDirectory}"
    MiddlewareUpdater::CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, options.slice(:middlewareLibraryName, :protobufDirectoryName).values, ourDirectory).work

    puts "Cleaning up Downloaded files"
    MiddlewareUpdater::RemoveDirectoryWorker.new(downloadFilePath).work
    MiddlewareUpdater::RemoveDirectoryWorker.new(temporaryDirectory).work

    puts "Moving protobuf files from Dependencies to our project directory"
    MiddlewareUpdater::CopyProtobufFilesWorker.new(ourDirectory, options[:protobufDirectoryName], options[:targetDirectoryPath]).work

    puts "Generate services from protobuf files"
    MiddlewareUpdater::RunCodegenScriptWorker.new(options[:swiftAutocodegenScript]).work
  end
end