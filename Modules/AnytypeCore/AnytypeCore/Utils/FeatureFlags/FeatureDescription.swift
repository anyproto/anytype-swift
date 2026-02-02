import Foundation

/// Category for UI organization. Does NOT affect runtime values.
public enum FeatureCategory: Equatable, Sendable {
    case developerTool
    case productFeature(author: String, targetRelease: String)

    public var author: String? {
        switch self {
        case .developerTool:
            return nil
        case .productFeature(let author, _):
            return author
        }
    }

    public var targetRelease: String? {
        switch self {
        case .developerTool:
            return nil
        case .productFeature(_, let targetRelease):
            return targetRelease
        }
    }
}

public struct FeatureDescription: Sendable {
    public let title: String
    public let category: FeatureCategory
    public let releaseAnytypeValue: Bool
    public let debugValue: Bool

    init(title: String, category: FeatureCategory, defaultValue: Bool, debugValue: Bool? = nil) {
        self.title = title
        self.category = category
        self.releaseAnytypeValue = defaultValue
        self.debugValue = debugValue ?? defaultValue
    }
}
