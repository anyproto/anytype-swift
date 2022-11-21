import BlocksModels

protocol RelationProtocol {
    var id: String { get }
    var key: String { get }
    var name: String { get }
    var isFeatured: Bool { get }
    var isEditable: Bool { get }
    var isBundled: Bool { get }
    
    var hasValue: Bool { get }
}
