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
    
    init(
        identifier: SubscriptionId,
        dataView: BlockDataview,
        view: DataviewView,
        groupFilter: DataviewFilter?,
        currentPage: Int
    ) {
        self.identifier = identifier
        self.source = dataView.source
        self.sorts = view.sorts
        var filters = view.filters
        if let groupFilter {
            filters.append(groupFilter)
        }
        self.filters = filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
    }
}
