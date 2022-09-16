import Foundation
import BlocksModels

struct SetSubsriptionData: Hashable {
    let source: [String]
    let sorts: [DataviewSort]
    let filters: [DataviewFilter]
    let options: [DataviewRelationOption]
    let currentPage: Int
    let coverRelationKey: String
    
    init(dataView: BlockDataview, view: DataviewView, currentPage: Int) {
        self.source = dataView.source
        self.sorts = view.sorts
        self.filters = view.filters
        self.options = view.options
        self.currentPage = currentPage
        self.coverRelationKey = view.coverRelationKey
    }
}
