import Foundation

public enum FeatureType: Equatable, Sendable {
    case debug
    case feature(author: String, releaseVersion: String)
}

public struct FeatureDescription: Sendable {
    public let title: String
    public let type: FeatureType
    public let defaultValue: Bool
    public let debugValue: Bool
    
    init(title: String, type: FeatureType, defaultValue: Bool, debugValue: Bool = true) {
        self.title = title
        self.type = type
        self.defaultValue = defaultValue
        self.debugValue = debugValue
    }
}
