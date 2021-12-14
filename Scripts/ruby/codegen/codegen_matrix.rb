class Matrix
  class Configuration
    class << self
      def protobufDirectory
        "#{__dir__}/../Modules/ProtobufMessages/Sources/"
      end
      def commandsFilePath
        self.protobufDirectory + "commands.pb.swift"
      end
      def modelsFilePath
        self.protobufDirectory + "models.pb.swift"
      end
      def eventsFilePath
        self.protobufDirectory + "events.pb.swift"
      end
      def localstoreFilePath
        self.protobufDirectory + "localstore.pb.swift"
      end
    end

    attr_accessor :transform, :filePath
    def initialize(transform, filePath)
      self.transform = transform
      self.filePath = filePath
    end

    def options
      {
        transform: transform,
        filePath: filePath,
      }
    end

    class << self
      def make_all
        [make_inits_for_commands, make_inits_for_models, make_inits_for_events, make_inits_for_localstore, make_error_protocols_for_commands, make_services_for_commands]
      end
      def make_error_protocols_for_commands
        new("error_protocol", self.commandsFilePath)
      end
      def make_services_for_commands
        new("services", self.commandsFilePath)
      end
      def make_inits_for_commands
        new("inits", self.commandsFilePath)
      end
      def make_inits_for_models
        new("inits", self.modelsFilePath)
      end
      def make_inits_for_events
        new("inits", self.eventsFilePath)
      end
      def make_inits_for_localstore
        new("inits", self.localstoreFilePath)
      end
    end
  end
end