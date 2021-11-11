import Foundation

struct ObjectRelationRowData: Hashable, Identifiable {
    let id = UUID()
    
    let name: String
    let value: ObjectRelationRowValue
    let hint: String
}
