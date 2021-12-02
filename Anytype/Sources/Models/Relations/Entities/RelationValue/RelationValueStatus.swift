import Foundation

extension RelationValue {
    
    struct Status: Hashable, Identifiable {
        let id: String
        let text: String
        let color: AnytypeColor
    }
    
}
