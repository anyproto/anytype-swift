require_relative 'base_pipeline'

class InstallPipeline
  def self.start(options)
    puts "Hey! You would like to install something, ok!"
    puts "Let's check lock file for a version."

    librarylockFilePath = options[:librarylockFilePath]
    unless File.exists? librarylockFilePath
      puts "I can't find library lock file at filepath #{librarylockFilePath} :("
    end

    version = MiddlewareUpdater::GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

    puts "We have version <#{version}> in a lock file!"

    self.work(version, options)
  end
end