import BlocksModels
import AnytypeCore

struct BlockBookmarkPayload: Hashable, Equatable {
    let url: String
    let title: String
    let subtitle: String
    let imageHash: String
    let faviconHash: String
    let isArchived: Bool
}

extension BlockBookmarkPayload {
    
    init(bookmarkData: BlockBookmark, objectDetails: ObjectDetails?) {

        if FeatureFlags.bookmarksFlow {
            self = objectDetails.map { BlockBookmarkPayload(objectDetails: $0, blockBookmark: bookmarkData) }
                ?? BlockBookmarkPayload(blockBookmark: bookmarkData)
        } else {
            self = BlockBookmarkPayload(blockBookmark: bookmarkData)
        }
    }
    
    private init(objectDetails: ObjectDetails, blockBookmark: BlockBookmark) {
        self.url = objectDetails.url
        self.title = objectDetails.title
        self.subtitle = objectDetails.description
        self.imageHash = objectDetails.picture
        self.faviconHash = objectDetails.iconImageHash?.value ?? ""
        self.isArchived = objectDetails.isArchived
    }
    
    private init(blockBookmark: BlockBookmark) {
        self.url = blockBookmark.url
        self.title = blockBookmark.title
        self.subtitle = blockBookmark.theDescription
        self.imageHash = blockBookmark.imageHash
        self.faviconHash = blockBookmark.faviconHash
        self.isArchived = false
    }
}
