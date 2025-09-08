import Foundation

struct ObjectTypeWidgetInfo: Equatable, Hashable, Identifiable {
    let objectTypeId: String
    
    var id: String { objectTypeId }
}
