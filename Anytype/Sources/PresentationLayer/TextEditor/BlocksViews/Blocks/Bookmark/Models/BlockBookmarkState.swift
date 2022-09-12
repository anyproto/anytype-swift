import BlocksModels
import AnytypeCore

struct BlockBookmarkPayload: Hashable, Equatable {
    let source: String
    let title: String
    let subtitle: String
    let imageHash: String
    let faviconHash: String
    let isArchived: Bool
}

extension BlockBookmarkPayload {
    
    private enum Constants {
        static let pictureRelationKey = "picture"
    }
    
    init(bookmarkData: BlockBookmark, objectDetails: ObjectDetails?) {

        if FeatureFlags.bookmarksFlow {
            self = objectDetails.map { BlockBookmarkPayload(objectDetails: $0, blockBookmark: bookmarkData) }
                ?? BlockBookmarkPayload(blockBookmark: bookmarkData)
        } else {
            self = BlockBookmarkPayload(blockBookmark: bookmarkData)
        }
    }
    
    private init(objectDetails: ObjectDetails, blockBookmark: BlockBookmark) {
        self.source = objectDetails.source
        self.title = objectDetails.title
        self.subtitle = objectDetails.description
        self.imageHash = BlockBookmarkPayload.picture(from: objectDetails)
        self.faviconHash = objectDetails.iconImage?.value ?? ""
        self.isArchived = objectDetails.isArchived
    }
    
    init(blockBookmark: BlockBookmark) {
        self.source = blockBookmark.source
        self.title = blockBookmark.title
        self.subtitle = blockBookmark.theDescription
        self.imageHash = blockBookmark.imageHash
        self.faviconHash = blockBookmark.faviconHash
        self.isArchived = false
    }
    
    private static func picture(from details: ObjectDetails) -> String {
         return details.values[Constants.pictureRelationKey]?.stringValue ?? ""
     }
}
