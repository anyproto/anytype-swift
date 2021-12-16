class ApplyTransformsCommand
  attr_accessor :transform
  def initialize(transform)
    self.transform = transform
  end
  def to_s
    "#{self.class.name} our_transform: #{self.our_transform}"
  end
end



class ApplyTransformsCommand
  module CodegenCLIScopes
    def self.suffix(scope, key)
      case scope
        when "memberwiseInitializer" then
          case key
            when :outputFilePath then "+Initializers"
            when :templateFilePath then nil #"+Initializers+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Initializers+Import"
          end
        when "serviceWithRequestAndResponse" then
          case key
            when :outputFilePath then "+Service"
            when :templateFilePath then "+Service+Template"
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then "+Service+Import"
          end
        when "errorAdoption" then
          case key
            when :outputFilePath then "+ErrorAdoption"
            when :templateFilePath then nil
            when :commentsHeaderFilePath then "+CommentsHeader"
            when :importsFilePath then nil
          end
      end
    end
  end
  def suffix_for_file(key)
    CodegenCLIScopes.suffix(transform, key)
  end
end