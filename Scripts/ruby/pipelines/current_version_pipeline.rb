class CurrentVersionPipeline
  def self.start(options)
    librarylockFilePath = options[:librarylockFilePath]
    unless File.exists? librarylockFilePath
      puts "I can't find library lock file at filepath #{librarylockFilePath} :("
    end

    version = GetLockfileVersionWorker.new(options[:librarylockFilePath], options[:librarylockFileVersionKey]).work

    puts "Lockfile Version: \n"
    puts "#{version}"
  end
end