import AnytypeCore
import Services

protocol TypesPinStorageProtocol {
    func getPins(spaceId: String) throws -> [ObjectType]
    func setPins(_ pins: [ObjectType], spaceId: String)
}

final class TypesPinStorage: TypesPinStorageProtocol {
    private let typeProvider: ObjectTypeProviderProtocol
    
    @UserDefault("widgetCollapsedIds", defaultValue: [:])
    private var storage: [String: [ObjectType]]
    
    init(typeProvider: ObjectTypeProviderProtocol) {
        self.typeProvider = typeProvider
    }
    
    func getPins(spaceId: String) throws -> [ObjectType] {
        if let pins = storage[spaceId] {
            return pins
        }
        
        let page = try typeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
        let note = try typeProvider.objectType(uniqueKey: .note, spaceId: spaceId)
        let task = try typeProvider.objectType(uniqueKey: .task, spaceId: spaceId)
        let defaultPins = [ note, page, task ]
        
        setPins(defaultPins, spaceId: spaceId)
        return defaultPins
    }
    
    func setPins(_ pins: [ObjectType], spaceId: String) {
        storage[spaceId] = pins
    }
}
