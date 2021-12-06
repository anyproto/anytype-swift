require_relative 'base_pipeline'

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