class UpdateCommand
  attr_accessor :version
  def initialize(version = nil)
    self.version = version
  end
end
