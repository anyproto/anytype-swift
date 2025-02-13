import Foundation

extension AttributedString {
    var isEmpty: Bool {
        characters.isEmpty
    }
    
    func trimmingCharacters(in set: CharacterSet) -> AttributedString {
        var mutableString = self

        while let firstCharacter = mutableString.characters.first, firstCharacter.unicodeScalars.contains(where: { set.contains($0) }) {
            mutableString.removeSubrange(mutableString.startIndex..<mutableString.index(mutableString.startIndex, offsetByCharacters: 1))
        }

        while let lastCharacter = mutableString.characters.last, lastCharacter.unicodeScalars.contains(where: { set.contains($0) }) {
            let lastIndex = mutableString.index(mutableString.endIndex, offsetByCharacters: -1)
            mutableString.removeSubrange(lastIndex..<mutableString.endIndex)
        }

        return mutableString
    }
}
