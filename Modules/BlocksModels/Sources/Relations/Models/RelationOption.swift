import Foundation

public struct RelationOption: Hashable {
    public let id: String
    public let text: String
    public let color: String
    public let scope: Scope
}

public extension RelationOption {
    
    init(details: ObjectDetails) {
        self.id = details.id
        self.text = details.relationOptionText
        self.color = details.relationOptionColor
        #warning("Fix scope")
//        self.scope = Scope(rawValue: middlewareOption.scope.rawValue)
        self.scope = .local
    }
}
