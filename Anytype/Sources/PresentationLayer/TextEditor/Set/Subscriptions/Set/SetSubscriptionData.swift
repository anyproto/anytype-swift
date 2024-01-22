import Foundation
import Services

struct SetSubscriptionData: Hashable {
    let identifier: String
    let source: [String]?
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let options: [DataviewRelationOption]
    let currentPage: Int
    let coverRelationKey: String
    let numberOfRowsPerPage: Int
    let collectionId: String?
    
    init(
        identifier: String,
        source: [String]?,
        view: DataviewView,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String]
    ) {
        self.identifier = identifier
        self.source = source
        
        var sorts = view.sorts
        if objectOrderIds.isNotEmpty {
            sorts.append(SearchHelper.customSort(ids: objectOrderIds))
        }
        self.sorts = sorts
        
        var filters = view.filters
        if let groupFilter {
            filters.append(groupFilter)
        }
        self.filters = filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
        self.numberOfRowsPerPage = numberOfRowsPerPage
        self.collectionId = collectionId
    }
}
