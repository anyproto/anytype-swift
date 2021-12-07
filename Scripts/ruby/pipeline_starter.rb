require_relative 'pipelines/install_pipeline'
require_relative 'pipelines/update_pipeline'
require_relative 'pipelines/list_pipeline'
require_relative 'pipelines/current_version_pipeline'

class PipelineStarter
  class << self
    def start(options)
      puts "Lets find you command in a list..."
      case options[:command]
      when Commands::InstallCommand then InstallPipeline.start(options)
      when Commands::UpdateCommand then UpdatePipeline.start(options)
      when Commands::ListCommand then ListPipeline.start(options)
      when Commands::CurrentVersionCommand then CurrentVersionPipeline.start(options)
      else
        puts "I don't recognize this command: #{options[:command]}"
        return
      end

      puts "Congratulations! You have just generated new protobuf files!"
    end
  end
end