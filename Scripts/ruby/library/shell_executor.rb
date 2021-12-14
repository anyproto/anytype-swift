require 'shellwords'

class ShellExecutor
  def self.run_command_line(line)
    puts "execute #{line}"

    result = %x(#{line})
    
    if $?.to_i != 0
      puts "Failed < #{result} > \n because of < #{$?} >"
      exit($?.to_i)
    end
    
    result
  end
end