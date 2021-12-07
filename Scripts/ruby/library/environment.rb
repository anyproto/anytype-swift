class EnvironmentVariables
  AVAILABLE_VARIABLES = {
    ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN: 'Access token to a middelware repositry'
  }
  def self.token
    ENV['ANYTYPE_IOS_MIDDLEWARE_ACCESS_TOKEN']
  end
  def self.variables_description
    AVAILABLE_VARIABLES.collect{|k, v| "#{k} -- #{v}"}.join('\n')
  end
end