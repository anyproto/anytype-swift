import Foundation

struct ObjectRelation: Hashable, Identifiable {
    let id = UUID()
    
    let icon: ObjectIconImage
    let text: String
}
