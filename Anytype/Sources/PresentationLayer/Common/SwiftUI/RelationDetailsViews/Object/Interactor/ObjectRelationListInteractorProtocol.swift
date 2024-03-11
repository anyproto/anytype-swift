import Services

@MainActor
protocol ObjectRelationListInteractorProtocol {
    var limitedObjectTypes: [ObjectType] { get }
    
    func searchOptions(text: String) async throws -> [ObjectRelationOption]
}
