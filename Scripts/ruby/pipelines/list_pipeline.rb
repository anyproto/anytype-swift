class ListPipeline
  def self.start(options)
    puts "Hey! You would like to list available versions?"
    puts "Lets fetch data from remote!"

    information = GetRemoteInformationWorker.new(options[:token], options[:repositoryURL]).work
    puts "I have gathered information!"

    puts "We have versions below"
    versions = GetRemoteAvailableVersionsWorker.new(information).work

    puts "Versions: \n"
    puts "#{JSON.pretty_generate(versions)}"
  end
end