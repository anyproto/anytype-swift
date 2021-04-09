import Foundation
import os


// MARK: Content
public extension Details.Information {
    enum Content {
        case title(Title)
        case iconEmoji(Emoji)
        case iconColor(OurHexColor)
        case iconImage(ImageId)
    }
}

// MARK: Content / Properties
public extension Details.Information.Content {
    /// This function returns an id for a `case`.
    /// This key we use for middleware details keys and also we use it to store our details in `[String : Content]` above in PageDetails.
    /// But it is still a key.
    ///
    /// - Returns: A key.
    func id() -> String {
        switch self {
        case let .title(value): return value.id
        case let .iconEmoji(value): return value.id
        case let .iconColor(value): return value.id
        case let .iconImage(value): return value.id
        }
    }
    
    /// This is "likeness" `id` that `erases associated value` of enum.
    /// We need it as id in dictionaries.
    ///
    func kind() -> Kind {
        switch self {
        case .title: return .title
        case .iconEmoji: return .iconEmoji
        case .iconColor: return .iconColor
        case .iconImage: return .iconImage
        }
    }
}

// MARK: DetailsMatching
// TODO: Rethink later. It should be done via Keys.
public extension Details.Information.Content {
    /// Actually, we could done this in the same way as EnvironemntKey and EnvironmentValues.
    enum Kind {
        case title
        case iconEmoji
        case iconColor
        case iconImage
    }
}

// MARK: Protocols
private protocol DetailsEntryIdentifiable {
    associatedtype ID
    static var id: ID {get}
}

// MARK: Content / Title
public extension Details.Information.Content {
    /// It is a custom detail.
    /// This detail refers to a `Title` that is coming in middleware `details`.
    /// Its id has value "name".
    /// But, it is doc, so, make sure that you use correct id if something goes wrong.
    ///
    struct Title {
        public private(set) var value: String = ""
        public private(set) var id: String = Self.id
        
        // MARK: - Memberwise initializer
        /// We should explicitly provide public access level to memberwise initializer.
        public init(value: String = "", id: String = Self.id) {
            self.value = value
            self.id = id
        }
    }
}

// MARK: Content / Title / Key
extension Details.Information.Content.Title: DetailsEntryIdentifiable {
    public static var id: String = "name"
}

// MARK: Content / IconEmoji
public extension Details.Information.Content {
    struct Emoji {
        public private(set) var value: String = ""
        public private(set) var id: String = Self.id

        // MARK: - Memberwise initializer
        public init(value: String = "", id: String = Self.id) {
            self.value = value
            self.id = id
        }
    }
}

// MARK: Content / IconEmoji / Key
extension Details.Information.Content.Emoji: DetailsEntryIdentifiable {
    public static var id: String = "iconEmoji"
}

// MARK: Content / IconColor
public extension Details.Information.Content {
    struct OurHexColor {
        public private(set) var value: String = ""
        public private(set) var id: String = Self.id

        // MARK: - Memberwise initializer
        public init(value: String = "", id: String = Self.id) {
            self.value = value
            self.id = id
        }
    }
}

// MARK: Content / IconColor / Key
extension Details.Information.Content.OurHexColor: DetailsEntryIdentifiable {
    public static var id: String = "iconColor"
}

// MARK: Content / IconColor
public extension Details.Information.Content {
    struct ImageId {
        public private(set) var value: String = ""
        public private(set) var id: String = Self.id

        // MARK: - Memberwise initializer
        public init(value: String = "", id: String = Self.id) {
            self.value = value
            self.id = id
        }
    }
}

// MARK: Content / IconColor / Key
extension Details.Information.Content.ImageId: DetailsEntryIdentifiable {
    public static var id: String = "iconImage"
}

// MARK: Hashable
extension Details.Information.Content: Hashable {}
extension Details.Information.Content.Title: Hashable {}
extension Details.Information.Content.Emoji: Hashable {}
extension Details.Information.Content.OurHexColor: Hashable {}
extension Details.Information.Content.ImageId: Hashable {}
