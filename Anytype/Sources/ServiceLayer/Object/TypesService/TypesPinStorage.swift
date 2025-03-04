import AnytypeCore
import Services

protocol TypesPinStorageProtocol: Sendable {
    func getPins(spaceId: String) throws -> [ObjectType]
    func setPins(_ pins: [ObjectType], spaceId: String)
    func appendPin(_ pin: ObjectType, spaceId: String) throws
    func removePin(typeId: String, spaceId: String) throws
}

final class TypesPinStorage: TypesPinStorageProtocol, Sendable {
    
    private let typeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let storage = UserDefaultStorage<[String: [ObjectType]]>(key: "pinnedTypes", defaultValue: [:])
    
    func getPins(spaceId: String) throws -> [ObjectType] {
        if let pins = storage.value[spaceId] {
            let objectTypeIds = typeProvider.objectTypes(spaceId: spaceId)
                .filter { !$0.isArchived }
                .filter { !$0.isDeleted }
                .filter { $0.canCreateObjectOfThisType }
            
            return objectTypeIds.filter {
                pins.map(\.id).contains($0.id)
            }
        }
        
        let page = try typeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
        let note = try typeProvider.objectType(uniqueKey: .note, spaceId: spaceId)
        let task = try typeProvider.objectType(uniqueKey: .task, spaceId: spaceId)
        let defaultPins = [ note, page, task ]
        
        setPins(defaultPins, spaceId: spaceId)
        return defaultPins
    }
    
    func setPins(_ pins: [ObjectType], spaceId: String) {
        storage.value[spaceId] = pins
    }
    
    func appendPin(_ pin: ObjectType, spaceId: String) throws {
        var pins = try getPins(spaceId: spaceId)
        pins.insert(pin, at: 0)
        setPins(pins, spaceId: spaceId)
    }
    
    func removePin(typeId: String, spaceId: String) throws {
        var pins = try getPins(spaceId: spaceId)
        pins.removeAll { $0.id == typeId }
        setPins(pins, spaceId: spaceId)
    }
}
