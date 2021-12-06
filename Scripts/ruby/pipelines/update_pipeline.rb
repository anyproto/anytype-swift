require_relative 'base_pipeline'

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

    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work
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
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work

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
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    say "I have gathered information!"

    version = GetRemoteVersionWorker.new(information).work

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

  def self.say(messages)
    Voice.say messages
  end
end