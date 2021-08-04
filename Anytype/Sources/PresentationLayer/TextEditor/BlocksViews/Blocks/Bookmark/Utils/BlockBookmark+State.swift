import BlocksModels

extension BlockBookmark {
    
    var blockBookmarkState: BlockBookmarkState {
        if url.isEmpty {
            return .empty
        }
        
        if title.isEmpty {
            return .onlyURL(url)
        }
        
        return .fetched(payload)
    }

    private var payload: BlockBookmarkPayload {
        return BlockBookmarkPayload(
            url: url,
            title: title,
            subtitle: theDescription,
            imageHash: imageHash,
            faviconHash: faviconHash
        )
    }
}
