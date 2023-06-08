import AnytypeCore

enum ObjectIconType: Hashable {
    case basic(String)
    case profile(Profile)
    case emoji(Emoji)
    case bookmark(String)
    case space(Space)
}

// MARK: - ProfileIcon

extension ObjectIconType {
    
    enum Profile: Hashable {
        case imageId(String)
        case character(Character)
        case gradient(GradientId)
    }
    
}

extension ObjectIconType {
    enum Space: Hashable {
        case character(Character)
        case gradient(GradientId)
    }
}

struct GradientId: Hashable {
    
    private static let range = 1..<17
    
    let rawValue: Int
    
    init?(_ value: Int) {
        guard GradientId.range.contains(value) else {
            return nil
        }
        self.rawValue = value
    }
    
    private init(unsafeValue: Int) {
        self.rawValue = unsafeValue
    }
    
    static var random: GradientId {
        GradientId(unsafeValue: Int.random(in: GradientId.range))
    }
}
