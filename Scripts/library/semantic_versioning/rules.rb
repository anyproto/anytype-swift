module SemanticVersioning
  module Rules
  end
end

module SemanticVersioning::Rules
  module Operators
    class Abstract
      attr_accessor :token
      def initialize(token)
        self.token = token
      end
    end
    class Greater < Abstract
      # Operator '>'
      # Examples:
      # > 0.1 # Any version higher than 0.1
      # > 0.1.0 # Any version higher than 0.1.0
    end
    class GreaterOrEqual < Abstract
      # Operator '>='
      # Examples:
      # >= 0.1 # Any version higher than or equal 0.1
      # >= 0.1.0 # Any version higher than or equal 0.1.0
    end
    class Less < Abstract
      # Operator '<'
      # Examples:
      # < 0.1 # Any version less than 0.1
      # < 0.1.0 # Any version less than 0.1.0
    end
    class LessThanOrEqual < Abstract
      # Operator '<='
      # Examples:
      # <= 0.1 # Any version less than or equal 0.1
      # <= 0.1.0 # Any version less than or equal 0.1.0
    end
    class Optimistic < Abstract
      # Operator '~>'
      # Examples: 
      # ~> 0.1.0 # Any version higher than or equal to 0.1.0 and less than 0.2
      # ~> 0.1 # Any version higher than or equal to 0.1 and less than 1
      # ~> 0 # Any version
    end
  end
end

module SemanticVersioning::Rules::Operators
  class Factory
    @@operators = nil
    def self.create_operators
      [
        Greater.new('>'),
        GreaterOrEqual.new('>='),
        Less.new('<'),
        LessThanOrEqual.new('<='),
        Optimistic.new('~>')
      ]
    end
    def self.operators
      @@operators ||= self.create_operators
    end
  end
end

module SemanticVersioning::Rules
  module Matcher
    def self.tokens
      # actually, we should sort them by length and by letters.
      Operators::Factory.operators.map(&:token).sort{|a, b| b.length <=> a.length}
    end
    def self.operator(token)
      Operators::Factory.operators.find{|x| x.token == token}
    end
  end
end

module SemanticVersioning::Rules
  class Rule
    attr_accessor :rule
    def self.allowed_tokens
      Matcher.tokens
    end
    def self.find_operator(token)
      Matcher.operator(token)
    end
    def self.build_regex(tokens)
      string = tokens.join('|')
      %r((#{string}))
    end
    def self.parsing(restrction)
      tokens = self.allowed_tokens
      regex = self.build_regex(tokens)
      restrction.match(regex)
    end
    def self.parse(restrction)
      parsed = self.parsing(restrction)
      unless parsed.nil?
        token = parsed.captures.first
        self.find_operator(token)
      else
        nil
      end
    end
  end
end

module SemanticVersioning::Tests
  module Rules
    def self.printAll(v)
      puts "Rule: #{v.to_s}"
    end
    def self.tests
      [ "~>1", ">= 0.1", "> 0.1.1", "< 0.2", "<=0.2.1", "~> 1.0" ].each do |x|
        printAll(SemanticVersioning::Rules::Rule.parse(x))
      end
    end
  end
end

# SemanticVersioning::Tests::Rules.tests