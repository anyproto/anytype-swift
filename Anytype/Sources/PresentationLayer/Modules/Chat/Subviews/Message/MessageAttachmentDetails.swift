import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let layoutValue: DetailsLayout
    let objectIconImage: Icon
    let objectType: ObjectType
    let editorScreenData: EditorScreenData
}

extension MessageAttachmentDetails {
    init(details: ObjectDetails) {
        self = MessageAttachmentDetails(
            id: details.id,
            title: details.title,
            layoutValue: details.layoutValue,
            objectIconImage: details.objectIconImage,
            objectType: details.objectType,
            editorScreenData: details.editorScreenData()
        )
    }
}
