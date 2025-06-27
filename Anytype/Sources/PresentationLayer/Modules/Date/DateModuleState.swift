import Foundation
import Services

struct DateModuleState: Equatable, Hashable {
    var selectedRelation: PropertyDetails? = nil { didSet { resetLimit() } }
    var sortType: DataviewSort.TypeEnum = .desc { didSet { resetLimit() } }
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
