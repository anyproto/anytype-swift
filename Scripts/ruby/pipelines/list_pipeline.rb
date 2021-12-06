class ListPipeline
  def self.start(options)
    say "Hey! You would like to list available versions?"
    say "Lets fetch data from remote!"

    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    say "I have gathered information!"

    say "We have versions below"
    versions = GetRemoteAvailableVersionsWorker.new(information).work

    say "Versions: \n"
    say "#{JSON.pretty_generate(versions)}"
  end
end