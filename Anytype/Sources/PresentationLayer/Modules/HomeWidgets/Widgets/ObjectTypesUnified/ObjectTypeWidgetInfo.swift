import Foundation
import Services

struct ObjectTypeWidgetInfo: Identifiable, Equatable, Hashable {
    let objectTypeId: String
    let spaceId: String
    let name: String
    let icon: ObjectIcon
    let canCreateObject: Bool

    var id: String { objectTypeId }
}
