import Services
import AnytypeCore

struct SpaceCardModel: Equatable, Identifiable {
    let spaceViewId: String
    let targetSpaceId: String
    let objectIconImage: Icon
    let nameWithPlaceholder: String
    let isPinned: Bool
    let isLoading: Bool
    let isShared: Bool
    let isMuted: Bool
    let uxTypeName: String
    let supportsMultiChats: Bool
    let isOneToOne: Bool

    let lastMessage: MessagePreviewModel?
    let unreadCounter: Int
    let mentionCounter: Int
    let hasCounters: Bool

    let wallpaper: SpaceWallpaperType

    var id: String { spaceViewId }
}
