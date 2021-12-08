module Commands
  class BaseCommand
    def to_json(*args)
      self.class.name
    end
  end

  class InstallCommand < BaseCommand
  end

  class UpdateCommand < BaseCommand
    attr_accessor :version
    def initialize(version = nil)
      self.version = version
    end
  end
end
