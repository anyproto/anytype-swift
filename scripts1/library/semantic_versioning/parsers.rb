require_relative './version'
require_relative './rules'

module SemanticVersioning
  module Parsers
  end
end

module SemanticVersioning::Parsers
  class VersionRange
    include SemanticVersioning::Rules::Operators
    attr_accessor :rule, :version
    def is_allowed?(new_version)
      case rule
      when Greater then new_version > version
      when GreaterOrEqual then new_version >= version
      when Less then new_version < version
      when LessThanOrEqual then new_version <= version
      when Optimistic then (new_version >= version) && (new_version < version.nextBig)
      else
        # Unknown rule
        false
      end
    end

    def to_s
      "#{self.rule.token} #{self.version}" # ------- #{self.rule}"
    end

    # ClassMethods
    def self.create(rule, version)
      if rule && version
        value = self.new
        value.rule = rule
        value.version = version
        value
      else
        nil
      end
    end
  end
end

module SemanticVersioning::Parsers
  # Actually, Parse can parse a string with both Rules and Version.
  class Parser
    # Class Methods
    def self.parse(string)
      rule = SemanticVersioning::Rules::Rule.parse(string)
      remains = string.gsub(rule.token, "").strip
      version = SemanticVersioning::Version.parse(remains)
      VersionRange.create(rule, version)
    end
  end
end

module SemanticVersioning::Tests
  module Parsers
    def self.printAll(parsed, version)
      puts "parsed: #{parsed}"
      puts "version: #{version}"
      puts "allowed? #{parsed.is_allowed?(version)}"
    end
    def self.tests
      [ ["~>1", "2"], 
        ["~>0.1", "0.2"],
        [">0.1.1", "0.2"],
        ["<0.2", "0.1"], 
        ["<=0.2.1", "0.2.1"], 
        [">1.0", "3"]
      ]
      .each do |x|
        parsed = SemanticVersioning::Parsers::Parser.parse(x[0])
        version = SemanticVersioning::Version.parse(x[1])
        printAll(parsed, version)
      end
    end
  end
end

# SemanticVersioning::Tests::Parsers.tests