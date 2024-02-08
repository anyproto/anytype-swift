import Services

@MainActor
protocol ObjectRelationListInteractorProtocol {
    var limitedObjectTypes: [ObjectType] { get }
    var canDuplicateObject: Bool { get }
    
    func searchOptions(text: String) async throws -> [ObjectRelationOption]
}
