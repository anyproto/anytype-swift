import SwiftUI
import Services

struct MessageAttachmentDetails: Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let layoutValue: DetailsLayout
    let objectIconImage: Icon
    let loadingState: Bool
}

extension MessageAttachmentDetails {
    init(details: ObjectDetails) {
        self = MessageAttachmentDetails(
            id: details.id,
            title: details.title,
            description: details.objectType.name,
            layoutValue: details.layoutValue,
            objectIconImage: details.objectIconImage,
            loadingState: false
        )
    }
    
    static func placeholder(tagetId: String) -> Self {
        MessageAttachmentDetails(
            id: tagetId,
            title: "Placeholder",
            description: "Placeholder",
            layoutValue: .basic,
            objectIconImage: .object(.empty(.page)),
            loadingState: true
        )
    }
}
