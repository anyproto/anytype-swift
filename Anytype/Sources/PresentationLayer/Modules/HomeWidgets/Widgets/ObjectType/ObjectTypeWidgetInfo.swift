import Foundation

struct ObjectTypeWidgetInfo: Equatable, Hashable, Identifiable {
    let objectTypeId: String
    let spaceId: String
    
    var id: String { objectTypeId }
}
