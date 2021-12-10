require 'yaml'

require_relative 'base_pipeline'
require_relative '../workers_hub'
require_relative '../constants'

class InstallPipeline < BasePipeline
  def self.start(options)
    librarylockFilePath = Constants::librarylockFilePath
    unless File.exists? librarylockFilePath
      puts "I can't find library lock file at filepath #{librarylockFilePath} :("
    end

    (YAML.load File.open(librarylockFilePath))[Constants::LOCKFILE_VERSION_KEY]

    puts "We have version <#{version}> in a lock file!"

    self.work(version, options)
  end
end