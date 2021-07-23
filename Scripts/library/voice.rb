class Voice
  class << self
    def say(messages)
      if ENV["SIRI_VOICE"] == "1"
        # not sure where it is defined.
        output = messages.is_a?(Array) ? messages : [messages]
        # puts "result: #{output}"
        puts "#{output}"
        # Fastlane::Actions::SayAction.run text: result_to_output
        %x(say #{output})
        nil
      else
        write messages
      end
    end
    def write(messages)
      puts messages
    end
  end
end
