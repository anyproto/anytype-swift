import Services
import AnytypeCore
import Factory

protocol SpaceCardModelBuilderProtocol: AnyObject, Sendable {
    func build(
        from spaces: [ParticipantSpaceViewDataWithPreview],
        wallpapers: [String: SpaceWallpaperType]
    ) async -> [SpaceCardModel]
}

final class SpaceCardModelBuilder: SpaceCardModelBuilderProtocol, Sendable {

    private let chatPreviewDateFormatter = ChatPreviewDateFormatter()
    @Injected(\.chatViewsStorage)
    private var chatViewsStorage: any ChatViewsStorageProtocol

    func build(
        from spaces: [ParticipantSpaceViewDataWithPreview],
        wallpapers: [String: SpaceWallpaperType]
    ) async -> [SpaceCardModel] {
        await Task.detached {
            spaces.map { spaceData in
                self.buildModel(from: spaceData, wallpapers: wallpapers)
            }
        }.value
    }

    private func buildModel(
        from spaceData: ParticipantSpaceViewDataWithPreview,
        wallpapers: [String: SpaceWallpaperType]
    ) -> SpaceCardModel {
        let spaceView = spaceData.spaceView
        let latestPreview = spaceData.latestPreview

        let lastMessage = latestPreview.lastMessage.map { lastMessagePreview in
            let attachments = lastMessagePreview.attachments.prefix(3).map { objectDetails in
                MessagePreviewModel.Attachment(
                    id: objectDetails.id,
                    icon: objectDetails.objectIconImage
                )
            }

            let chatId = latestPreview.chatId
            let chatName = chatViewsStorage.chat(id: chatId)?.name

            return MessagePreviewModel(
                creatorTitle: lastMessagePreview.creator?.title,
                text: lastMessagePreview.text,
                attachments: Array(attachments),
                localizedAttachmentsText: lastMessagePreview.localizedAttachmentsText,
                chatPreviewDate: chatPreviewDateFormatter.localizedDateString(for: lastMessagePreview.createdAt, showTodayTime: true),
                unreadCounter: 0, // unsupported in space hub
                mentionCounter: 0, // unsupported in space hub
                isMuted: false, // unsupported in space hub
                chatName: chatName
            )
        }

        return SpaceCardModel(
            spaceViewId: spaceView.id,
            targetSpaceId: spaceView.targetSpaceId,
            objectIconImage: spaceView.objectIconImage,
            nameWithPlaceholder: spaceView.name.withPlaceholder,
            isPinned: spaceView.isPinned,
            isLoading: spaceView.isLoading,
            isShared: spaceView.isShared,
            isMuted: !spaceView.pushNotificationMode.isUnmutedAll,
            uxTypeName: spaceView.uxType.name,
            uxType: spaceView.uxType,
            lastMessage: lastMessage,
            unreadCounter: spaceData.totalUnreadCounter,
            mentionCounter: spaceData.totalMentionCounter,
            hasCounters: spaceData.hasCounters,
            wallpaper: wallpapers[spaceView.targetSpaceId] ?? .default
        )
    }
}

extension Container {
    var spaceCardModelBuilder: Factory< any SpaceCardModelBuilderProtocol> {
        self { SpaceCardModelBuilder() }.shared
    }
}
