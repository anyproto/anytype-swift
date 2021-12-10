require_relative 'pipelines/install_pipeline'
require_relative 'pipelines/update_pipeline'

class PipelineStarter
  def self.start(options)
    case options[:command]
    when InstallCommand then 
      puts "Start to install"
      InstallPipeline.start(options)
    when UpdateCommand then 
      puts "Start to update"
      UpdatePipeline.start(options)
    else
      puts "Not supported command: #{options[:command]}"
      return
    end

    puts "Done 💫"
  end
end