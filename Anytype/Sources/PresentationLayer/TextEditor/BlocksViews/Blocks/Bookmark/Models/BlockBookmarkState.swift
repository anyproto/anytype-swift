import BlocksModels
import AnytypeCore

enum BlockBookmarkState: Hashable, Equatable {
    case onlyURL(String)
    case fetched(BlockBookmarkPayload)
}

struct BlockBookmarkPayload: Hashable, Equatable {
    let source: String
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
        
        if payload.source.isEmpty {
            return nil
        }
    
        if payload.title.isEmpty {
            self = .onlyURL(payload.source)
        }
        
        self = .fetched(payload)
    }
}

extension BlockBookmarkPayload {
    
    private enum Constants {
        static let pictureRelationKey = "picture"
    }
    
    init(objectDetails: ObjectDetails) {
        self.source = objectDetails.source
        self.title = objectDetails.title
        self.subtitle = objectDetails.description
        self.imageHash = BlockBookmarkPayload.picture(from: objectDetails)
        self.faviconHash = objectDetails.iconImageHash?.value ?? ""
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
