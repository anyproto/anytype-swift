import Services

protocol PropertyProtocol {
    var id: String { get }
    var key: String { get }
    var name: String { get }
    var isFeatured: Bool { get }
    var isEditable: Bool { get }
    var canBeRemovedFromObject: Bool { get }
    var isDeleted: Bool { get }
    
    var hasValue: Bool { get }
}
