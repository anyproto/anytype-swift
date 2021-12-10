require_relative 'pipelines/base_pipeline'
require_relative 'pipelines/version_provider'

class PipelineStarter
  def self.start(options)
    version = VersionProvider.version(options)
    BasePipeline.work(version, options)
    
    if options[:latest]
      update_version(version, options)
    end 

    puts "Done 💫"
  end

  def self.update_version(version, options)
    filePath = Constants::LIBRARY_FILE_PATH
    result = { Constants::LOCKFILE_VERSION_KEY => version}.to_yaml
    result = result.gsub(/^---\s+/, '')
    result = result.gsub(/:/, ': ~>')
    File.open(filePath, 'w') do |file_handler|
      file_handler.write(result)
      puts "Updated library file"
    end
  end
end