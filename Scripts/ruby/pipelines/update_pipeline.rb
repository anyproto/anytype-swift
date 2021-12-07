require_relative 'base_pipeline'

class UpdatePipeline < BasePipeline
  def self.store_version(version, options)
    puts "Saving version <#{version}> to library lock file."
    librarylockFilePath = options[:librarylockFilePath]
    SetLockfileVersionWorker.new(librarylockFilePath, version).work
  end
  def self.install_with_version(options)
    version = options[:command].version
    puts "Hey, you would like to install concrete version. #{version}"
    puts "Lets fetch data from remote!"

    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work
    if versions.include?(version)
      self.work(version, options)
      self.store_version(version, options)
    else 
      puts "I can't find version #{version}"
      puts "versions are: #{versions}"
    end
  end
  def self.install_with_restrictions(options)
    puts "Hey, you would like to install version with restrictions."
    puts "Lets gather restrictions!"

    # well, we could use another key, but keep it like in lock file.
    restrictions = GetLibraryfileVersionWorker.new(options[:libraryFilePath]).work

    puts "I have restrictions: #{restrictions}"

    unless restrictions
      puts "Restrctions are not valid at #{options[:libraryFilePath]}"
      return
    end

    puts "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work

    version = SemanticCompareVersionsWorker.new(restrictions, versions).work
    if version
      puts "I choose version: #{version}"
      self.work(version, options)
      self.store_version(version, options)
    else
      puts "I can't find appropriate version: #{version}"
    end
  end
  def self.install_without_restrictions(options)
    puts "Hey, you would like to install latest remote version!"
    puts "Lets fetch data from remote!"
    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    puts "I have gathered information!"

    version = GetRemoteVersionWorker.new(information).work

    puts "We have fresh version <#{version}> in remote!"
    self.work(version, options)
    self.store_version(version, options)
  end
  def self.start(options)
    puts "Hey! You would like to update something, ok!"

    if options[:command].version
      self.install_with_version(options)
      return
    end

    libraryFilePath = options[:libraryFilePath]
    unless File.exists? libraryFilePath
      puts "I can't find library file at filepath #{libraryFilePath}."
      # so, we have to install any version, right?
      self.install_without_restrictions(options)
    else
      self.install_with_restrictions(options)
    end
  end
end