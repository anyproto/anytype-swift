import Services
import SwiftUI

struct SetProperty: Identifiable, Hashable {
    let relationDetails: PropertyDetails
    let option: DataviewRelationOption
    
    var id: String { relationDetails.id }
}

extension Array where Element == DataviewRelationOption {
    func index(of relation: SetProperty) -> Index? {
        firstIndex(where: { $0.key == relation.relationDetails.key })
    }
    
    func index(of relation: DataviewRelationOption) -> Index? {
        firstIndex(where: { $0.key == relation.key })
    }
}
