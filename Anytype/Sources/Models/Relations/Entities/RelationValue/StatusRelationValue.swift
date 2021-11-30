import Foundation

struct StatusRelationValue: Hashable, Identifiable {
    let id = UUID()
    
    let text: String
    let color: AnytypeColor
    
}
