require_relative '../library/environment'
require_relative '../commands'

class DefaultOptions
  def self.options
    options = {
      command: Commands::InstallCommand.new,
      runsOnCI: false,
      token: EnvironmentVariables.token || '',
    }
  end
end