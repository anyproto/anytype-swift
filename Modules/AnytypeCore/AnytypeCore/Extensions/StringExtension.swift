public extension String {
    var isNotEmpty: Bool {
        !isEmpty
    }
    
    /// Returns trimmed string (without whitespaces and newlines at the edges).
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var replacedNewlinesWithSpaces: String {
        String(components(separatedBy: .newlines).joined(separator: " "))
    }
    
    var asAnytypeId: AnytypeId? {
        let id = AnytypeId(self)
        
        if id.isNil {
            anytypeAssertionFailure("Tried to create AnytypeId from invalid string", domain: .anytypeId)
        }
        
        return id
    }
    
}
