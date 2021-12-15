class ApplyTransformsCommand
  attr_accessor :transform
  def initialize(transform)
    self.transform = transform
  end
  def to_s
    "#{self.class.name} our_transform: #{self.our_transform} and tool_transform: #{self.tool_transform}"
  end
end



class ApplyTransformsCommand
  module CodegenCLIScopes
    def self.swift_codegen_option(scope)
      puts scope 
      exit 0
      case scope
      when ErrorProtocol then SwiftCodegenCLIOptions::GenerateOptions::ErrorAdoption
      when Initializers then SwiftCodegenCLIOptions::GenerateOptions::MemberwiseInitializer
      when Services then SwiftCodegenCLIOptions::GenerateOptions::ServiceWithRequestAndResponse
      end
    end
    def self.suffix(scope, key)
      case scope
        when Initializers then
          case key
            when :outputFilePath then "+Initializers"
            when :templateFilePath then nil #"+Initializers+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Initializers+Import"
          end
        when Services then
          case key
            when :outputFilePath then "+Service"
            when :templateFilePath then "+Service+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Service+Import"
          end
        when ErrorProtocol then
          case key
            when :outputFilePath then "+ErrorAdoption"
            when :templateFilePath then nil
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then nil
          end
      end
    end
  end

  def our_transform
    self.transform
  end
  def tool_transform
    CodegenCLIScopes.swift_codegen_option(self.our_transform)
  end
  def suffix_for_file(key)
    CodegenCLIScopes.suffix(self.our_transform, key)
  end
end