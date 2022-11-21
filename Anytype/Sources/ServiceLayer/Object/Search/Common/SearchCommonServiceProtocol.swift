import Foundation
import BlocksModels

protocol SearchCommonServiceProtocol: AnyObject {
    func search(
        filters: [DataviewFilter],
        sorts: [DataviewSort],
        fullText: String,
        limit: Int32
    ) -> [ObjectDetails]?
}

extension SearchCommonServiceProtocol {
    func search(
        filters: [DataviewFilter] = [],
        sorts: [DataviewSort] = [],
        fullText: String = "",
        limit: Int32 = 100
    ) -> [ObjectDetails]? {
        search(filters: filters, sorts: sorts, fullText: fullText, limit: limit)
    }
}
