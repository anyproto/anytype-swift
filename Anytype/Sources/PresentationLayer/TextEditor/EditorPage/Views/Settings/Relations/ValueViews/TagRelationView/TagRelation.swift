import Foundation

struct TagRelation: Hashable {
    
    let text: String
    let textColor: AnytypeColor
    let backgroundColor: AnytypeColor
    
}

extension TagRelation: Identifiable {
    
    var id: String {
        "\(text)\(textColor.rawValue)\(backgroundColor.rawValue)"
    }
    
}
