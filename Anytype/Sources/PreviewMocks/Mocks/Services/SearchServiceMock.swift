import Services

final class SearchServiceMock: SearchServiceProtocol, @unchecked Sendable {
    
    nonisolated static let shared = SearchServiceMock()
    
    private let details: [ObjectDetails]
    
    private init() {
        var details: [ObjectDetails] = []
        for i in 0..<300 {
            details.append(ObjectDetails.mock(name: "Object \(i)"))
        }
        self.details = details
    }
    
    func search(text: String, spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchFiles(text: String, excludedFileIds: [String],  spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchImages(spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func search(text: String, spaceId: String, limitObjectIds: [String]) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchObjects(spaceId: String, objectIds: [String]) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchObjectsByTypes(text: String, typeIds: [String], excludedObjectIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchTemplates(for type: String, spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchObjects(
        text: String,
        excludedObjectIds: [String],
        excludedLayouts: [DetailsLayout],
        spaceId: String,
        sortRelationKey: BundledPropertyKey?
    ) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchRelationOptions(text: String, relationKey: String, excludedObjectIds: [String], spaceId: String) async throws -> [PropertyOption] {
        return []
    }
    
    func searchRelationOptions(optionIds: [String], spaceId: String) async throws -> [PropertyOption] {
        return []}
    
    func searchRelations(text: String, excludedIds: [String], spaceId: String) async throws -> [PropertyDetails] {
        return []
    }
    
    func searchLibraryRelations(text: String, excludedIds: [String]) async throws -> [PropertyDetails] {
        return []
    }
    
    func searchArchiveObjectIds(spaceId: String) async throws -> [String] {
        return []
    }
    
    func searchObjectsWithLayouts(text: String, layouts: [DetailsLayout], excludedIds: [String], spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
    
    func searchAll(text: String, spaceId: String) async throws -> [ObjectDetails] {
        return details
    }
}
