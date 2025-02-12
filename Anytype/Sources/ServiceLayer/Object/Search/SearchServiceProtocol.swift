import Services


protocol SearchServiceProtocol: AnyObject, Sendable {
    func search(text: String, spaceId: String) async throws -> [ObjectDetails]
    func searchFiles(text: String, excludedFileIds: [String],  spaceId: String) async throws -> [ObjectDetails]
    func searchImages(spaceId: String) async throws -> [ObjectDetails]
    func search(text: String, spaceId: String, limitObjectIds: [String]) async throws -> [ObjectDetails]
    func searchObjects(spaceId: String, objectIds: [String]) async throws -> [ObjectDetails]
    func searchObjectsByTypes(text: String, typeIds: [String], excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails]
    func searchTemplates(for type: String, spaceId: String) async throws -> [ObjectDetails]
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        spaceId: String,
        sortRelationKey: BundledRelationKey?
    ) async throws -> [ObjectDetails]
    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String], spaceId: String) async throws -> [RelationOption]
    func searchRelationOptions(optionIds: [String], spaceId: String) async throws -> [RelationOption]
    func searchRelations(text: String, excludedIds: [String], spaceId: String) async throws -> [RelationDetails]
    func searchLibraryRelations(text: String, excludedIds: [String]) async throws -> [RelationDetails]
    func searchArchiveObjectIds(spaceId: String) async throws -> [String]
    func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], spaceId: String) async throws -> [ObjectDetails]
    func searchAll(text: String, spaceId: String) async throws -> [ObjectDetails]
}
