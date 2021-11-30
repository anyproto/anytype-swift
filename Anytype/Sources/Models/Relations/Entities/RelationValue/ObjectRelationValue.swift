import Foundation

struct ObjectRelationValue: Hashable, Identifiable {
    let id = UUID()
    
    let icon: ObjectIconImage
    let text: String
}
