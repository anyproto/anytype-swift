class SemanticCompareVersionsWorker
  attr_accessor :semantic_versioning_parsed, :versions
  def initialize(semantic_versioning_parsed, versions)
    self.semantic_versioning_parsed = semantic_versioning_parsed
    self.versions = versions
  end
  
  def work
    versions.find{|x| self.semantic_versioning_parsed.is_allowed?(SemanticVersioning::Version.parse(x))}
  end
end