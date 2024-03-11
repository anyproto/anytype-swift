import Foundation
import Services

extension BlockBookmark {
    
    init(objectDetails: ObjectDetails) {
        self.init(
            source: objectDetails.source,
            title: objectDetails.title,
            theDescription: objectDetails.description,
            imageObjectId: objectDetails.picture,
            faviconObjectId: objectDetails.iconImage,
            type: .unknown,
            targetObjectID: objectDetails.id,
            state: .done
        )
    }
}
