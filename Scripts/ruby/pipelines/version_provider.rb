require_relative 'base_pipeline'
require_relative '../constants'

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

    version = GetLibraryfileVersionWorker.new().work
    puts "Version in the library file: #{version}"

    information = GetRemoteInformationWorker.new(options[:token]).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work

    validatedVersion = SemanticCompareVersionsWorker.new(version, versions).work

    if validatedVersion
      return validatedVersion
    else
      puts "Can't find version: <#{version}> on the remote"
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