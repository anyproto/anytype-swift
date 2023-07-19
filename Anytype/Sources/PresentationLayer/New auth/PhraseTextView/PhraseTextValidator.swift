protocol PhraseTextValidatorProtocol {
    func validated(prevText: String, text : String) -> String
}

struct PhraseTextValidator: PhraseTextValidatorProtocol {
    
    private enum Constants {
        static let maxWordsCount = 12
        static let maxCharactersPerWordCount = 8
    }
    
    func validated(prevText: String, text : String) -> String {
        let textNoNewlines = text.trimmingCharacters(in: .newlines)
                let rawComponents = textNoNewlines.components(separatedBy: .whitespaces)
        let prevRawComponents = prevText.components(separatedBy: .whitespaces)
        
        let emptyRawComponentsCount = rawComponents.filter { $0.isEmpty }.count
        let emptyPrevRawComponentsCount = prevRawComponents.filter { $0.isEmpty }.count
        
        guard emptyRawComponentsCount != emptyPrevRawComponentsCount else { return textNoNewlines }
        
        var suffix = ""
        if rawComponents.count > 1 && (rawComponents.last?.isEmpty ?? false) {
            suffix = " "
        }
        
        let rawWords = rawComponents.filter { $0.isNotEmpty }
        let words = rawWords.prefix(Constants.maxWordsCount).map { word in
            if word.count > Constants.maxCharactersPerWordCount {
                return String(word.prefix(Constants.maxCharactersPerWordCount))
            } else {
                return word
            }
        }
        
        let result = words.joined(separator: " ") + suffix
                return result
    }
    
}

