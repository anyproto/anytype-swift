import BlocksModels

enum BlockBookmarkConverter {
    static func asResource(_ value: BlockBookmark) -> BlockBookmarkResource {
        if value.url.isEmpty {
            return .empty()
        }
        
        if value.title.isEmpty {
            return .onlyURL(
                .init(
                    url: value.url,
                    title: value.title,
                    subtitle: value.theDescription,
                    imageHash: value.imageHash,
                    iconHash: value.faviconHash
                )
            )
        }
        
        return .fetched(
            .init(
                url: value.url,
                title: value.title,
                subtitle: value.theDescription,
                imageHash: value.imageHash,
                iconHash: value.faviconHash
            )
        )
    }
}
