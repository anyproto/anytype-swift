import Foundation

public struct PropertyOption: Hashable, Sendable {
    public let id: String
    public let text: String
    public let color: String
}

public extension PropertyOption {
    
    init(details: ObjectDetails) {
        self.id = details.id
        self.text = details.name
        self.color = details.relationOptionColor
    }
}
