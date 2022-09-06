import BlocksModels

protocol RelationProtocol {
    var key: String { get }
    var name: String { get }
    var isFeatured: Bool { get }
    var isEditable: Bool { get }
    var isBundled: Bool { get }    
}
