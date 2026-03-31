import AnytypeCore
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

    @available(*, deprecated, message: "Use spaceType overload instead")
    init(
        identifier: String,
        document: some SetDocumentProtocol,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String],
        spaceUxType: SpaceUxType?
    ) {
        let layoutFilter = SearchHelper.layoutFilter(DetailsLayout.visibleLayoutsWithFiles(spaceUxType: spaceUxType))
        self.init(
            identifier: identifier,
            document: document,
            groupFilter: groupFilter,
            currentPage: currentPage,
            numberOfRowsPerPage: numberOfRowsPerPage,
            collectionId: collectionId,
            objectOrderIds: objectOrderIds,
            layoutFilter: layoutFilter
        )
    }

    init(
        identifier: String,
        document: some SetDocumentProtocol,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String],
        spaceType: SpaceType?
    ) {
        let layoutFilter = SearchHelper.layoutFilter(DetailsLayout.visibleLayoutsWithFiles(spaceType: spaceType))
        self.init(
            identifier: identifier,
            document: document,
            groupFilter: groupFilter,
            currentPage: currentPage,
            numberOfRowsPerPage: numberOfRowsPerPage,
            collectionId: collectionId,
            objectOrderIds: objectOrderIds,
            layoutFilter: layoutFilter
        )
    }

    private init(
        identifier: String,
        document: some SetDocumentProtocol,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int,
        collectionId: String?,
        objectOrderIds: [String],
        layoutFilter: DataviewFilter
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
                type: .desc
            ))
        }
        self.sorts = sorts

        // Filters
        var filters = view.filters
            .enrichingFormats(with: document.dataViewRelationsDetails)
            .removingUnsupportedFilters()
        if let groupFilter {
            filters.append(groupFilter)
        }
        filters.append(layoutFilter)
        filters.append(contentsOf: SearchHelper.notHiddenFilters())
        filters.append(SearchHelper.filterOutParticipantType())
        self.filters = filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
        self.numberOfRowsPerPage = numberOfRowsPerPage
        self.collectionId = collectionId
        self.spaceId = document.spaceId
    }
}
