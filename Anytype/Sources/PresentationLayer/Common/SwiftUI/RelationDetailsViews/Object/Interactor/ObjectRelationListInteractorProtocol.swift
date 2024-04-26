import Services

@MainActor
protocol ObjectRelationListInteractorProtocol {
    var limitedObjectTypes: [ObjectType] { get }
    
    func searchOptions(text: String, limitObjectIds: [String]) async throws -> [ObjectRelationOption]
    func searchOptions(text: String, excludeObjectIds: [String]) async throws -> [ObjectRelationOption]
}
