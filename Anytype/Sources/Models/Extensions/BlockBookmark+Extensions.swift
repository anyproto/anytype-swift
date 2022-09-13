import Foundation
import BlocksModels

extension BlockBookmark {
    
    private enum Constants {
        static let pictureRelationKey = "picture"
    }
    
    init(objectDetails: ObjectDetails) {
        self.init(
            source: objectDetails.source,
            title: objectDetails.title,
            theDescription: objectDetails.description,
            imageHash: objectDetails.picture?.value ?? "",
            faviconHash: objectDetails.iconImage?.value ?? "",
            type: .unknown,
            targetObjectID: objectDetails.id,
            state: .done
        )
    }
}
