import Foundation
import Services

extension SpaceView: IdProvider {}

struct SpaceView {
    let id: String
    let title: String
    let icon: Icon?
    let targetSpaceId: String
}

extension SpaceView {
    init(details: ObjectDetails) {
        self.id = details.id
        self.title = details.title
        self.icon = details.objectIconImage
        self.targetSpaceId = details.targetSpaceId
    }
}
