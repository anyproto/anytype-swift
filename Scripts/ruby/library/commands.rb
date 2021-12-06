require 'json'
module Commands
  class BaseCommand
    def to_json(*args)
      self.class.name
    end
  end
end