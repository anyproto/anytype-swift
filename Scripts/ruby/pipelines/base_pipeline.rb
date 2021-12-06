class BasePipeline
  def self.work(version, options)
    say "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    say "I have gathered information!"

    say "Now lets find our url to release!"
    assetURL = GetRemoteAssetURLWorker.new(information, version, options[:iOSAssetMiddlewarePrefix]).work
    say "Our URL is: #{assetURL}"

    downloadFilePath = options[:downloadFilePath]
    say "Start downloading library to #{downloadFilePath}"
    DownloadFileAtURLWorker.new(options[:token], assetURL, options[:downloadFilePath]).work
    say "Library is downloaded at #{downloadFilePath}"

    temporaryDirectory = MiddlewareUpdater::GetTemporaryDirectoryWorker.new.work
    say "Start uncompressing to directory #{temporaryDirectory}"
    MiddlewareUpdater::UncompressFileToTemporaryDirectoryWorker.new(downloadFilePath, temporaryDirectory).work

    ourDirectory = options[:dependenciesDirectoryPath]
    say "Cleaning up Dependencies directory #{ourDirectory}"
    MiddlewareUpdater::CleanupDependenciesDirectoryWorker.new(ourDirectory).work

    say "Moving files from temporaryDirectory #{temporaryDirectory} to ourDirectory: #{ourDirectory}"
    MiddlewareUpdater::CopyLibraryArtifactsFromTemporaryDirectoryToTargetDirectoryWorker.new(temporaryDirectory, options.slice(:middlewareLibraryName, :protobufDirectoryName).values, ourDirectory).work

    say "Cleaning up Downloaded files"
    MiddlewareUpdater::RemoveDirectoryWorker.new(downloadFilePath).work
    MiddlewareUpdater::RemoveDirectoryWorker.new(temporaryDirectory).work

    say "Moving protobuf files from Dependencies to our project directory"
    MiddlewareUpdater::CopyProtobufFilesWorker.new(ourDirectory, options[:protobufDirectoryName], options[:targetDirectoryPath]).work

    say "Generate services from protobuf files"
    MiddlewareUpdater::RunCodegenScriptWorker.new(options[:swiftAutocodegenScript]).work
  end

  def say(messages)
      Voice.say messages
    end
end