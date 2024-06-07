import Foundation
import ProtobufMessages

public struct SearchResultWithMeta: Sendable {
    public let objectDetails: ObjectDetails
    public let meta: [SearchMeta]
    
    init(objectDetails: ObjectDetails, meta: [SearchMeta]) {
        self.objectDetails = objectDetails
        self.meta = meta
    }
}

public extension Array where Element == Anytype_Model_Search.Result {
    var asResults: [SearchResultWithMeta] {
        compactMap { result -> SearchResultWithMeta? in
            guard let objectDetails = result.details.asDetails else { return nil }
            return SearchResultWithMeta(objectDetails: objectDetails, meta: result.meta)
        }
    }
}
