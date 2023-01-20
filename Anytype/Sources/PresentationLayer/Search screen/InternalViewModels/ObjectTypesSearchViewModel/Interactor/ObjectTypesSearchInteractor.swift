import Foundation
import BlocksModels
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    private let showSet: Bool
    
    init(
        searchService: SearchServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        excludedObjectTypeId: String?,
        showBookmark: Bool,
        showSet: Bool
    ) {
        self.searchService = searchService
        self.workspaceService = workspaceService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
        self.showSet = showSet
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) -> [ObjectDetails] {
        searchService.searchObjectTypes(
            text: text,
            filteringTypeId: excludedObjectTypeId,
            shouldIncludeSets: showSet,
            shouldIncludeBookmark: showBookmark
        ) ?? []
    }
    
    func searchInMarketplace(text: String) -> [ObjectDetails] {
        return searchService.searchMarketplaceObjectTypes(text: text, includeInstalled: false) ?? []
    }
    
    func installType(objectId: String) -> ObjectDetails? {
        return workspaceService.installObject(objectId: objectId)
    }
}

