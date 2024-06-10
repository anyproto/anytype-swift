import Foundation

public struct RelationOption: Hashable, Sendable {
    public let id: String
    public let text: String
    public let color: String
}

public extension RelationOption {
    
    init(details: ObjectDetails) {
        self.id = details.id
        self.text = details.name
        self.color = details.relationOptionColor
    }
}
