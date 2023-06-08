extension String {
    
    var containsEmoji: Bool {
        contains { $0.isEmoji }
    }
}
