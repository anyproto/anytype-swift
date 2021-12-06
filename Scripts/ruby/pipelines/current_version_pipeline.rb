class CurrentVersionPipeline
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