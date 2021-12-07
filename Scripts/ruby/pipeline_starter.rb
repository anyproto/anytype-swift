require_relative 'pipelines/install_pipeline'
require_relative 'pipelines/update_pipeline'
require_relative 'pipelines/list_pipeline'
require_relative 'pipelines/current_version_pipeline'

class PipelineStarter
  def self.start(options)
    case options[:command]
    when Commands::InstallCommand then InstallPipeline.start(options)
    when Commands::UpdateCommand then UpdatePipeline.start(options)
    when Commands::ListCommand then ListPipeline.start(options)
    else
      puts "I don't recognize this command: #{options[:command]}"
      return
    end

    puts "Done 💫"
  end
end