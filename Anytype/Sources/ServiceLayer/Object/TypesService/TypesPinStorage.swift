import AnytypeCore
import Services

protocol TypesPinStorageProtocol {
    func getPins(spaceId: String) throws -> [ObjectType]
    func setPins(_ pins: [ObjectType], spaceId: String)
    func appendPin(_ pin: ObjectType, spaceId: String) throws
    func removePin(typeId: String, spaceId: String) throws
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
