import Services

@MainActor
protocol ObjectPropertyListInteractorProtocol {
    var limitedObjectTypes: [ObjectType] { get }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectPropertyOption]
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectPropertyOption]
}
