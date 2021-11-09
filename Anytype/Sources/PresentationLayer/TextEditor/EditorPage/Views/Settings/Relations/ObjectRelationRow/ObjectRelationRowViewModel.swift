import Foundation

struct ObjectRelationRowViewModel: Hashable, Identifiable {
    let id = UUID()
    
    let name: String
    let value: ObjectRelationRowValue
    let hint: String
}
