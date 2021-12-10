require_relative 'pipelines/update_pipeline'

class PipelineStarter
  def self.start(options)
    UpdatePipeline.start(options)
    puts "Done 💫"
  end
end