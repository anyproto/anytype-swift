import Foundation
import Services
import AnytypeCore

final class Legacy_ObjectTypeSearchInteractor {
    
    private let spaceId: String
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    private let showSetAndCollection: Bool
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        spaceId: String,
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSetAndCollection: Bool
    ) {
        self.spaceId = spaceId
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
        self.showSetAndCollection = showSetAndCollection
        self.objectTypeProvider = objectTypeProvider
    }
    
}

extension Legacy_ObjectTypeSearchInteractor {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await searchService.searchObjectTypes(
            text: text,
            filteringTypeId: excludedObjectTypeId,
            shouldIncludeSets: showSetAndCollection,
            shouldIncludeCollections: showSetAndCollection,
            shouldIncludeBookmark: showBookmark,
            spaceId: spaceId
        )
    }
    
    func searchInLibrary(text: String) async throws -> [ObjectDetails] {
        let excludedIds = objectTypeProvider.objectTypes(spaceId: spaceId).map(\.sourceObject)
        return try await searchService.searchLibraryObjectTypes(text: text, excludedIds: excludedIds)
    }
    
    func installType(objectId: String) async throws -> ObjectDetails {
        try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
    }
}

