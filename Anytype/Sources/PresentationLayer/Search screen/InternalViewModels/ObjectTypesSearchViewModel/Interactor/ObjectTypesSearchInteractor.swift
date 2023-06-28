import Foundation
import Services
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    private let showSetAndCollection: Bool
    
    init(
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSetAndCollection: Bool
    ) {
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
        self.showSetAndCollection = showSetAndCollection
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjectTypes(
            text: text,
            filteringTypeId: excludedObjectTypeId,
            shouldIncludeSets: showSetAndCollection,
            shouldIncludeCollections: showSetAndCollection,
            shouldIncludeBookmark: showBookmark
        )
    }
    
    func searchInMarketplace(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchMarketplaceObjectTypes(text: text, includeInstalled: false)
    }
    
    func installType(objectId: String) -> ObjectDetails? {
        return workspaceService.installObject(objectId: objectId)
    }
}

