extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        
        return firstScalar.properties.isEmoji && firstScalar.value >= 0x231A
    }

    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool {
        unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false
    }

    public var isEmoji: Bool {
        isSimpleEmoji || isCombinedIntoEmoji
    }
    
}
