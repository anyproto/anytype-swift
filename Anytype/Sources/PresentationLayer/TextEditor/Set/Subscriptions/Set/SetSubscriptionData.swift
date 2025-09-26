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
    let spaceId: String
    
    init(
        identifier: String,
        document: some SetDocumentProtocol,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String]
    ) {
        self.identifier = identifier
        self.source = document.details?.filteredSetOf
        
        let view = document.activeView
        
        // Sorts
        var sorts = view.sorts
        if objectOrderIds.isNotEmpty {
            sorts.append(SearchHelper.customSort(relationKey: BundledPropertyKey.id.rawValue, values: objectOrderIds))
        }
        let setSorts = document.sorts(for: view.id)
        sorts = sorts.map { sort in
            guard let setSort = setSorts.first(where: { $0.sort.id == sort.id }) else {
                return sort
            }
            var newSort = sort
            newSort.format = setSort.relationDetails.format.asMiddleware
            return newSort
        }
        if sorts.isEmpty {
            sorts.append(SearchHelper.sort(
                relation: .createdDate,
                type: .desc,
                includeTime: true
            ))
        }
        self.sorts = sorts
        
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
        self.spaceId = document.spaceId
    }
}
