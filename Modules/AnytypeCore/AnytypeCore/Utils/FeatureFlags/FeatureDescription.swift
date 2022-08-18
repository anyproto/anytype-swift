import Foundation

public struct FeatureDescription {
    public let title: String
    public let author: String
    public let releaseVersion: String
    public let defaultValue: Bool
    public let debugValue: Bool
}

public extension FeatureDescription {
    init(title: String, author: String, releaseVersion: String, defaultValue: Bool) {
        self.init(
            title: title,
            author: author,
            releaseVersion: releaseVersion,
            defaultValue: defaultValue,
            debugValue: true
        )
    }
}
