import BlocksModels
import AnytypeCore

enum BlockBookmarkState: Hashable, Equatable {
    case onlyURL(String)
    case fetched(BlockBookmarkPayload)
}

struct BlockBookmarkPayload: Hashable, Equatable {
    let url: String
    let title: String
    let subtitle: String
    let imageHash: String
    let faviconHash: String
    let isArchived: Bool
}

extension BlockBookmarkState {
    
    init?(bookmarkData: BlockBookmark, objectDetails: ObjectDetails?) {

        let payload: BlockBookmarkPayload
        if FeatureFlags.bookmarksFlow {
            payload = objectDetails.map { BlockBookmarkPayload(objectDetails: $0) }
                ?? BlockBookmarkPayload(blockBookmark: bookmarkData)
        } else {
            payload = BlockBookmarkPayload(blockBookmark: bookmarkData)
        }
        
        if payload.url.isEmpty {
            return nil
        }
    
        if payload.title.isEmpty {
            self = .onlyURL(payload.url)
        }
        
        self = .fetched(payload)
    }
}

extension BlockBookmarkPayload {
    
    init(objectDetails: ObjectDetails) {
        self.url = objectDetails.url
        self.title = objectDetails.title
        self.subtitle = objectDetails.description
        self.imageHash = objectDetails.picture
        self.faviconHash = objectDetails.iconImageHash?.value ?? ""
        self.isArchived = objectDetails.isArchived
    }
    
    init(blockBookmark: BlockBookmark) {
        self.url = blockBookmark.url
        self.title = blockBookmark.title
        self.subtitle = blockBookmark.theDescription
        self.imageHash = blockBookmark.imageHash
        self.faviconHash = blockBookmark.faviconHash
        self.isArchived = false
    }
}
