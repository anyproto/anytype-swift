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
    
    var asAnytypeID: AnytypeID? {
        AnytypeID(self)
    }
    
}
