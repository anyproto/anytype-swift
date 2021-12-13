require_relative 'base_pipeline'
require_relative '../constants'
require_relative '../library/lib_version'

class VersionProvider
  def self.version(options)
    if options[:latest] 
      latest_version(options)
    else
      version_from_library_file(options)
    end
  end

  def self.version_from_library_file(options)
    libraryFilePath = Constants::LIBRARY_FILE_PATH
    unless File.exists? libraryFilePath
      puts "I can't find library file at #{libraryFilePath}."
      exit 1
    end

    version = LibraryVersion.get()
    puts "Version in the library file: #{version}"

    information = GetRemoteInformationWorker.new(options[:token]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work


    if versions.include?(version)
      return version
    else
      puts "Can't find version #{version} on the remote"
      puts "Available versions: #{versions}"
      exit 1
    end
  end

  def self.latest_version(options)
    information = GetRemoteInformationWorker.new(options[:token]).work
    version = GetRemoteVersionWorker.new(information).work
    puts "Latest version in remote <#{version}>"

    return version
  end
end