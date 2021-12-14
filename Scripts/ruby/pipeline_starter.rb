require_relative 'pipelines/base_pipeline'
require_relative 'pipelines/version_provider'
require_relative 'library/lib_version'

class PipelineStarter
  def self.start(options)
    unless options[:artifactsPath].empty?
      puts "Install library from path #{options[:artifactsPath]}"
      install_library_from_path(options[:artifactsPath])
      return
    end

    if options[:latest]
      install_latest_library(options)
    else
      install_library_from_libfile(options)
    end
  end

  private_class_method def self.install_library_from_path(path)    
    BasePipeline.work(path)
    done()
  end

  private_class_method def self.install_latest_library(options)
    version = VersionProvider.latest_version(options[:token])
    actifacts_dir = DownloadMiddlewarePipeline.work(version, options)
    
    BasePipeline.work(actifacts_dir)
    LibraryFile.set(version)
    
    cleanup(actifacts_dir)
    done()
  end

  private_class_method def self.install_library_from_libfile(options)
    version = VersionProvider.version_from_library_file(options[:token])
    actifacts_dir = DownloadMiddlewarePipeline.work(version, options)
    
    BasePipeline.work(actifacts_dir)

    cleanup(actifacts_dir)
    done()
  end

  private_class_method def self.cleanup(dir)
    puts "Cleaning up artifacts"
    FileUtils.remove_entry dir
  end

  private_class_method def self.done
    puts "Done 💫"
    `afplay /System/Library/Sounds/Glass.aiff`
  end
end