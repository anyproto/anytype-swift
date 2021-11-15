import Foundation

struct StatusRelation: Hashable, Identifiable {
    let id = UUID()
    
    let text: String
    let color: AnytypeColor
    
}
