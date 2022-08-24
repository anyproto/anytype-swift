import BlocksModels

extension BlockBookmark {
    
    var blockBookmarkState: BlockBookmarkState? {
        if source.isEmpty {
            return nil
        }
        
        if title.isEmpty {
            return .onlyURL(source)
        }
        
        return .fetched(payload)
    }

    private var payload: BlockBookmarkPayload {
        return BlockBookmarkPayload(
            source: source,
            title: title,
            subtitle: theDescription,
            imageHash: imageHash,
            faviconHash: faviconHash
        )
    }
}
