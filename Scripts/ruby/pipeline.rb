require 'optparse'
require 'shellwords'
require 'pathname'

require 'tmpdir'

require 'net/http'

require 'yaml'
require 'json'

require_relative 'library/shell_executor'
require_relative 'library/voice'
require_relative 'library/workers'
require_relative 'library/semantic_versioning'
require_relative 'library/commands'

require_relative 'configuration'

class Pipeline
  class BasePipeline < Pipeline
    def self.work(version, options)
      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      say "Now lets find our url to release!"
      assetURL = MiddlewareUpdater::GetRemoteAssetURLWorker.new(information, version, options[:iOSAssetMiddlewarePrefix]).work
      say "Our URL is: #{assetURL}"

      downloadFilePath = options[:downloadFilePath]
      say "Start downloading library to #{downloadFilePath}"
      MiddlewareUpdater::DownloadFileAtURLWorker.new(options[:token], assetURL, options[:downloadFilePath]).work
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
  end
  class InstallPipeline < BasePipeline
    def self.start(options)
      say "Hey! You would like to install something, ok!"
      say "Let's check lock file for a version."

      librarylockFilePath = options[:librarylockFilePath]
      unless File.exists? librarylockFilePath
        say "I can't find library lock file at filepath #{librarylockFilePath} :("
      end

      version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

      say "We have version <#{version}> in a lock file!"

      self.work(version, options)
    end
  end
  class UpdatePipeline < BasePipeline
    def self.store_version(version, options)
      say "Saving version <#{version}> to library lock file."
      librarylockFilePath = options[:librarylockFilePath]
      MiddlewareUpdater::SetLockfileVersionWorker.new(librarylockFilePath, options[:librarylockFileVersionKey], version).work
    end
    def self.install_with_version(options)
      version = options[:command].version
      say "Hey, you would like to install concrete version. #{version}"
      say "Lets fetch data from remote!"

      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work
      if versions.include?(version)
        self.work(version, options)
        self.store_version(version, options)
      else 
        say "I can't find version #{version}"
        say "versions are: #{versions}"
      end
    end
    def self.install_with_restrictions(options)
      say "Hey, you would like to install version with restrictions."
      say "Lets gather restrictions!"

      # well, we could use another key, but keep it like in lock file.
      restrictions = MiddlewareUpdater::GetLibraryfileVersionWorker.new(options[:libraryFilePath], options[:librarylockFileVersionKey]).work

      say "I have restrictions: #{restrictions}"

      unless restrictions
        say "Restrctions are not valid at #{options[:libraryFilePath]}"
        return
      end

      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work

      version = MiddlewareUpdater::SemanticCompareVersionsWorker.new(restrictions, versions).work
      if version
        say "I choose version: #{version}"
        self.work(version, options)
        self.store_version(version, options)
      else
        say "I can't find appropriate version: #{version}"
      end
    end
    def self.install_without_restrictions(options)
      say "Hey, you would like to install latest remote version!"
      say "Lets fetch data from remote!"
      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      version = MiddlewareUpdater::GetRemoteVersionWorker.new(information).work

      say "We have fresh version <#{version}> in remote!"
      self.work(version, options)
      self.store_version(version, options)
    end
    def self.start(options)
      say "Hey! You would like to update something, ok!"

      if options[:command].version
        self.install_with_version(options)
        return
      end

      libraryFilePath = options[:libraryFilePath]
      unless File.exists? libraryFilePath
        say "I can't find library file at filepath #{libraryFilePath}."
        # so, we have to install any version, right?
        self.install_without_restrictions(options)
      else
        self.install_with_restrictions(options)
      end
    end
  end
  class ListPipeline < Pipeline
    def self.start(options)
      say "Hey! You would like to list available versions?"
      say "Lets fetch data from remote!"

      information = MiddlewareUpdater::GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
      say "I have gathered information!"

      say "We have versions below"
      versions = MiddlewareUpdater::GetRemoteAvailableVersionsWorker.new(information).work

      say "Versions: \n"
      say "#{JSON.pretty_generate(versions)}"
    end
  end
  class CurrentVersionPipeline < Pipeline
    def self.start(options)
      say "Hey! You would like to print current version from Lockfile, ok!"
      say "Let's check lock file for a version."

      librarylockFilePath = options[:librarylockFilePath]
      unless File.exists? librarylockFilePath
        say "I can't find library lock file at filepath #{librarylockFilePath} :("
      end

      version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

      say "Lockfile Version: \n"
      say "#{version}"
    end
  end
  class << self
    def say(messages)
      Voice.say messages
    end
    def start(options)
      say "Lets find you command in a list..."
      case options[:command]
      when MiddlewareUpdater::Configuration::Commands::InstallCommand then InstallPipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::UpdateCommand then UpdatePipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::ListCommand then ListPipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::CurrentVersionCommand then CurrentVersionPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        finalize
        return
      end

      say "Congratulations! You have just generated new protobuf files!"
      finalize
    end

    def finalize
      puts "Goodbye!"
    end
  end
end
