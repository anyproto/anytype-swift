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
            imageHash: BlockBookmark.picture(from: objectDetails),
            faviconHash: objectDetails.iconImageHash?.value ?? "",
            type: .unknown,
            targetObjectID: objectDetails.id,
            state: .done
        )
    }
    
    private static func picture(from details: ObjectDetails) -> String {
        return details.values[Constants.pictureRelationKey]?.stringValue ?? ""
    }
}
