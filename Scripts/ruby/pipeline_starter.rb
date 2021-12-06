require_relative 'pipelines/install_pipeline'
require_relative 'pipelines/update_pipeline'
require_relative 'pipelines/list_pipeline'
require_relative 'pipelines/current_version_pipeline'

class PipelineStarter
  class << self
    def say(messages)
      Voice.say messages
    end
    def start(options)
      say "Lets find you command in a list..."
      case options[:command]
      when MiddlewareUpdater::Configuration::Commands::InstallCommand then InstallPipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::UpdateCommand then UpdatePipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::ListCommand then ListPipeline.start(options)
      when MiddlewareUpdater::Configuration::Commands::CurrentVersionCommand then CurrentVersionPipeline.start(options)
      else
        say "I don't recognize this command: #{options[:command]}"
        return
      end

      say "Congratulations! You have just generated new protobuf files!"
    end
  end
end