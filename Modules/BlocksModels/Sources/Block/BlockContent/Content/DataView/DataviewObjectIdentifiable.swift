public protocol DataviewObjectIdentifiable {
    var id: String { get }
}

extension DataviewSort: DataviewObjectIdentifiable {}

extension DataviewFilter: DataviewObjectIdentifiable {}

extension DataviewRelationOption: DataviewObjectIdentifiable {
    public var id: String {
        key
    }
}
