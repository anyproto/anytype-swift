class CurrentVersionPipeline
  def self.start(options)
    puts "Hey! You would like to print current version from Lockfile, ok!"
    puts "Let's check lock file for a version."

    librarylockFilePath = options[:librarylockFilePath]
    unless File.exists? librarylockFilePath
      puts "I can't find library lock file at filepath #{librarylockFilePath} :("
    end

    version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

    puts "Lockfile Version: \n"
    puts "#{version}"
  end
end