import Foundation
import BlocksModels

extension BlockBookmark {
    init(objectDetails: ObjectDetails) {
        self.init(
            source: objectDetails.source,
            title: objectDetails.title,
            theDescription: objectDetails.description,
            imageHash: objectDetails.picture,
            faviconHash: objectDetails.iconImageHash?.value ?? "",
            type: .unknown,
            targetObjectID: objectDetails.id,
            state: .done
        )
    }
}
