import BlocksModels

enum BlockBookmarkConverter {
    static func asResource(_ bookmark: BlockBookmark) -> BlockBookmarkResource {
        if bookmark.url.isEmpty {
            return .empty()
        }
        
        if bookmark.title.isEmpty {
            return .onlyURL(bookmark.payload)
        }
        
        return .fetched(bookmark.payload)
    }
}

extension BlockBookmark {
    var payload: BlockBookmarkPayload {
        return BlockBookmarkPayload(
            url: url,
            title: title,
            subtitle: theDescription,
            imageHash: imageHash,
            iconHash: faviconHash
        )
    }
}
