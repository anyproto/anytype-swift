import Foundation
import BlocksModels
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    
    init(searchService: SearchServiceProtocol, excludedObjectTypeId: String?, showBookmark: Bool) {
        self.searchService = searchService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) -> [ObjectDetails] {
        searchService.searchObjectTypes(
            text: text,
            filteringTypeUrl: excludedObjectTypeId,
            shouldIncludeSets: false,
            shouldIncludeBookmark: FeatureFlags.showBookmarkInSets ? showBookmark : false
        ) ?? []
    }
    
}

