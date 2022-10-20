import Foundation
import BlocksModels
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectTypeId: String?
    
    init(searchService: SearchServiceProtocol, excludedObjectTypeId: String?) {
        self.searchService = searchService
        self.excludedObjectTypeId = excludedObjectTypeId
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) -> [ObjectDetails] {
        searchService.searchObjectTypes(
            text: text,
            filteringTypeUrl: excludedObjectTypeId,
            shouldIncludeSets: false,
            shouldIncludeBookmark: FeatureFlags.showBookmarkInSets
        ) ?? []
    }
    
}

