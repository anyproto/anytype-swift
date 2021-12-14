require_relative 'pipelines/base_pipeline'
require_relative 'pipelines/version_provider'
require_relative 'library/lib_version'

class PipelineStarter
  def self.start(options)
    version = VersionProvider.version(options)
    BasePipeline.work(version, options)
    
    if options[:latest]
      LibraryVersion.set(version)
    end 

    puts "Done 💫"
    `afplay /System/Library/Sounds/Glass.aiff`
  end
end