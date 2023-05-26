require_relative '../constants'
require_relative '../library/lib_version'

class VersionProvider
  def self.version_from_library_file(token)
    version = LibraryFile.get()

    return specific_version(version, token)
  end

  def self.specific_version(version, token)
    information = GetRemoteInformationWorker.new(token).work
    versions = GetRemoteAvailableVersionsWorker.new(information).work

    if versions.include?(version)
      return version
    else
      puts "Can't find version #{version} on the remote"
      puts "Available versions: #{versions}"
      exit 1
    end
  end

  def self.latest_version(token)
    information = GetRemoteInformationWorker.new(token).work
    version = GetRemoteVersionWorker.new(information).work
    puts "Latest version in remote <#{version}>"

    return version
  end
end