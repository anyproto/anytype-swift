module SemanticVersioning
  class Version
    include Comparable
    module Comparison
      def self.compareParts(lhs, rhs)
        (lhs || 0) <=> (rhs || 0)
      end
      def self.compare(lhs, rhs)
        if lhs.is_a?(Infinity) && rhs.is_a?(Infinity)
          return 0 <=> 0
        end

        if lhs.is_a? Infinity
          return 1 <=> 0
        end

        if rhs.is_a? Infinity
          return 0 <=> 1
        end
        [compareParts(lhs.major, rhs.major), compareParts(lhs.minor, rhs.minor), compareParts(lhs.patch, rhs.patch)].find{|x| x != 0} || 0
      end
    end

    module Iterator
      def self.nextPatched(version)
        major = version.major
        minor = version.minor || 0
        patch = version.patch || 0
        Version.create(major, minor, patch + 1)
      end
      def self.next(version)
        major = version.major
        minor = version.minor
        patch = version.patch
        unless patch.nil?
          return Version.create(major, minor, patch + 1)
        end
        unless minor.nil?
          return Version.create(major, minor + 1, patch)
        end
        unless major.nil?
          return Version.create(major + 1, minor, patch)
        end
        version
      end
      def self.nextBig(version)
        major = version.major
        minor = version.minor
        patch = version.patch
        unless patch.nil?
          return Version.create(major, minor + 1, patch)
        end
        unless minor.nil?
          return Version.create(major + 1, minor, patch)
        end
        unless major.nil?
          return Version::Infinity.new
        end
      end
    end

    # Embedding
    def nextPatched
      Iterator.nextPatched self
    end

    def next
      Iterator.next self
    end

    def nextBig
      Iterator.nextBig self
    end

    def <=>(other)
      Comparison.compare(self, other)
    end

    class Infinity < Version
      def to_s
        self.class
      end
      def inspect
        self.class
      end
    end

    def inspect
      {
        major: major,
        minor: minor,
        patch: patch
      }
    end
    def to_s
      [((major || 0).to_s), (minor.nil? ? "" : minor.to_s), (patch.nil? ? "" : patch.to_s)].join(".")
    end

    attr_accessor :major, :minor, :patch

    class << self
      def parsing(version)
        version.match(/(\d+)\.?(\d+)?\.?(\d+)?/)
      end
      def create(major, minor, patch)
        value = self.new
        value.major = major
        value.minor = minor
        value.patch = patch
        value
      end
      def parse(version)
        parsed = self.parsing(version)
        unless parsed.nil?
          captures = parsed.captures
          data = captures.map{|x| x.nil? ? x : x.to_i}
          self.create(data[0], data[1], data[2])
        else
          nil
        end
      end
    end
  end
end

module SemanticVersioning::Tests
  module Version
    def self.printAll(v)
      puts "version: #{v.to_s}"
      puts "patched: #{v.nextPatched.to_s}"
      puts "next: #{v.next.to_s}"
      puts "big: #{v.nextBig.to_s}"
    end
    def self.tests
      [ "1", "0.1", "0.1.1", "0.2", "0.2.1", "1.0" ].each do |x|
        printAll(SemanticVersioning::Version.parse(x))
      end
    end
  end
end

# SemanticVersioning::Tests::Version.tests