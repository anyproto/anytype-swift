import Foundation
import BlocksModels

struct SetSubsriptionData: Hashable {
    let identifier: SubscriptionId
    let source: [String]
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let options: [DataviewRelationOption]
    let currentPage: Int
    let coverRelationKey: String
    let numberOfRowsPerPage: Int
    
    init(
        identifier: SubscriptionId,
        source: [String],
        view: DataviewView,
        groupFilter: DataviewFilter?,
        currentPage: Int,
        numberOfRowsPerPage: Int
    ) {
        self.identifier = identifier
        self.source = source
        self.sorts = view.sorts
        var filters = view.filters
        if let groupFilter {
            filters.append(groupFilter)
        }
        self.filters = filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
        self.numberOfRowsPerPage = numberOfRowsPerPage
    }
}
