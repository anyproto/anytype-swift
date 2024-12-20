import Foundation

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

    /// check if string has percent encoding
    var isEncoded: Bool {
        return removingPercentEncoding != self
    }
    
    func trimmed(numberOfCharacters: Int, suffix: String = "...") -> String {
        if count > numberOfCharacters {
            return String(prefix(numberOfCharacters)) + suffix
        }
        
        return self
    }
    
    func removing(in characterSet: CharacterSet) -> String {
        return components(separatedBy: characterSet).joined()
    }
    
    func decodedBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
