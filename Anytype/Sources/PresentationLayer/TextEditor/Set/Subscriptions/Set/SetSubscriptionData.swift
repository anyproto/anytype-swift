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
        document: SetDocumentProtocol,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String]
    ) {
        self.identifier = identifier
        self.source = document.details?.setOf
        
        let view = document.activeView
        
        // Sorts
        var sorts = view.sorts
        if objectOrderIds.isNotEmpty {
            sorts.append(SearchHelper.customSort(ids: objectOrderIds))
        }
        let setSorts = document.sorts(for: view.id)
        self.sorts = sorts.map { sort in
            guard let setSort = setSorts.first(where: { $0.sort.id == sort.id }) else {
                return sort
            }
            var newSort = sort
            newSort.format = setSort.relationDetails.format.asMiddleware
            return newSort
        }
        
        // Filters
        var filters = view.filters
        if let groupFilter {
            filters.append(groupFilter)
        }
        filters.append(SearchHelper.layoutFilter(DetailsLayout.visibleLayoutsWithFiles))
        filters.append(contentsOf: SearchHelper.notHiddenFilters())
        self.filters = filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
        self.numberOfRowsPerPage = numberOfRowsPerPage
        self.collectionId = collectionId
    }
}
