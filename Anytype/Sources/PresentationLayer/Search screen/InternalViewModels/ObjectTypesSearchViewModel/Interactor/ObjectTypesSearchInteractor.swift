import Foundation
import BlocksModels
import AnytypeCore

final class ObjectTypesSearchInteractor {
    
    private let searchService: SearchServiceProtocol
    private let excludedObjectTypeId: String?
    private let showBookmark: Bool
    private let showSet: Bool
    
    init(searchService: SearchServiceProtocol, excludedObjectTypeId: String?, showBookmark: Bool, showSet: Bool) {
        self.searchService = searchService
        self.excludedObjectTypeId = excludedObjectTypeId
        self.showBookmark = showBookmark
        self.showSet = showSet
    }
    
}

extension ObjectTypesSearchInteractor {
    
    func search(text: String) -> [ObjectDetails] {
        searchService.searchObjectTypes(
            text: text,
            filteringTypeUrl: excludedObjectTypeId,
            shouldIncludeSets: FeatureFlags.showSetsInChangeTypeSearchMenu ? showSet : false,
            shouldIncludeBookmark: FeatureFlags.showBookmarkInSets ? showBookmark : false
        ) ?? []
    }
    
}

