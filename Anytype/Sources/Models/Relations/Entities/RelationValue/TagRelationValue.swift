import Foundation

struct TagRelationValue: Hashable, Identifiable {
    let id = UUID()
    
    let text: String
    let textColor: AnytypeColor
    let backgroundColor: AnytypeColor
    
}
