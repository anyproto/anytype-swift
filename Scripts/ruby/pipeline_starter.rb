require_relative 'pipelines/base_pipeline'
require_relative 'pipelines/version_provider'
require_relative 'library/lib_version'

class PipelineStarter
  def self.start(options)
    unless options[:artifactsPath].empty?
      puts "Install library from path #{options[:artifactsPath]}"
      install_library_from_path(options[:artifactsPath])
      return
    else
      install_library_from_remote()
    end
  end

  private_class_method def self.install_library_from_path(path)    
    BasePipeline.work(path)
    
    puts "Done 💫"
    `afplay /System/Library/Sounds/Glass.aiff`
  end

  private_class_method def self.install_library_from_remote
    version = VersionProvider.version(options)
    dir = DownloadMiddlewarePipeline.work(version, options)
    
    BasePipeline.work(dir)

    puts "Cleaning up artifacts"
    FileUtils.remove_entry dir
    
    if options[:latest]
      LibraryVersion.set(version)
    end 

    puts "Done 💫"
    `afplay /System/Library/Sounds/Glass.aiff`
  end
end