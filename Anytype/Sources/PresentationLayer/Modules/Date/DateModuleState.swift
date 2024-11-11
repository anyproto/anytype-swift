import Foundation
import Services

struct DateModuleState: Equatable, Hashable {
    var selectedRelation: RelationDetails? = nil { didSet { resetLimit() } }
    var currentDate: Date? = nil { didSet { resetLimit() } }
    var limit = Constants.limit
    
    mutating func updateLimit() {
        limit += Constants.limit
    }
    
    private mutating func resetLimit() {
        limit = Constants.limit
    }
    
    var scrollId: String {
        selectedRelation?.id ?? ""
    }
    
    private enum Constants {
        static let limit = 100
    }
}
