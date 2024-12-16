import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let layoutValue: DetailsLayout
    let objectIconImage: Icon
}

extension MessageAttachmentDetails {
    init(details: ObjectDetails) {
        self = MessageAttachmentDetails(
            id: details.id,
            title: details.title,
            description: details.objectType.name,
            layoutValue: details.layoutValue,
            objectIconImage: details.objectIconImage
        )
    }
}
