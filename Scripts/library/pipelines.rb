require_relative 'voice'

module Pipelines
  class BasePipeline
    class << self
      def say(messages)
        Voice.say messages
      end
      def start(options)
        say "Default pipeline has been chosen. Implement start method."
      end
      def finalize
        puts "Goodbye!"
      end
    end
  end
end