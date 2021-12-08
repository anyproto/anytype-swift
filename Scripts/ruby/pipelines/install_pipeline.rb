require_relative 'base_pipeline'
require_relative '../workers_hub'

class InstallPipeline < BasePipeline
  def self.start(options)
    librarylockFilePath = options[:librarylockFilePath]
    unless File.exists? librarylockFilePath
      puts "I can't find library lock file at filepath #{librarylockFilePath} :("
    end

    version = GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

    puts "We have version <#{version}> in a lock file!"

    self.work(version, options)
  end
end