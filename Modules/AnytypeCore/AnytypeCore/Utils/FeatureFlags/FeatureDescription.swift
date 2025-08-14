import Foundation

public enum FeatureType: Equatable, Sendable {
    case debug
    case feature(author: String, releaseVersion: String)
    
    public var author: String? {
        switch self {
        case .debug:
            return nil
        case .feature(let author, _):
            return author
        }
    }
    
    public var releaseVersion: String? {
        switch self {
        case .debug:
            return nil
        case .feature(_, let releaseVersion):
            return releaseVersion
        }
    }
}

public struct FeatureDescription: Sendable {
    public let title: String
    public let type: FeatureType
    public let releaseAnytypeValue: Bool
    public let releaseAnyAppValue: Bool
    public let debugValue: Bool
    
    init(title: String, type: FeatureType, releaseAnytypeValue: Bool, releaseAnyAppValue: Bool, debugValue: Bool = true) {
        self.title = title
        self.type = type
        self.releaseAnytypeValue = releaseAnytypeValue
        self.releaseAnyAppValue = releaseAnyAppValue
        self.debugValue = debugValue
    }
    
    init(title: String, type: FeatureType, defaultValue: Bool, debugValue: Bool = true) {
        self.title = title
        self.type = type
        self.releaseAnytypeValue = defaultValue
        self.releaseAnyAppValue = defaultValue
        self.debugValue = debugValue
    }
}
