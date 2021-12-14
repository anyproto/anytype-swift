class CodegenCommand
end

class CodegenListCommand
  attr_accessor :list
  def initialize(options)
    self.list = options
  end
end