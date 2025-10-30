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

    private let historyDateFormatter = HistoryDateFormatter()
    private let chatPreviewDateFormatter = ChatPreviewDateFormatter()

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
        let preview = spaceData.preview

        let lastMessage = preview.lastMessage.map { lastMessagePreview in
            let attachments = lastMessagePreview.attachments.prefix(3).map { objectDetails in
                SpaceCardLastMessageModel.Attachment(
                    id: objectDetails.id,
                    icon: objectDetails.objectIconImage
                )
            }

            return SpaceCardLastMessageModel(
                creatorTitle: lastMessagePreview.creator?.title,
                text: lastMessagePreview.text,
                attachments: Array(attachments),
                localizedAttachmentsText: lastMessagePreview.localizedAttachmentsText,
                historyDate: historyDateFormatter.localizedDateString(for: lastMessagePreview.createdAt, showTodayTime: true),
                chatPreviewDate: chatPreviewDateFormatter.localizedDateString(for: lastMessagePreview.createdAt, showTodayTime: true)
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
            isMuted: FeatureFlags.muteSpacePossibility && !spaceView.pushNotificationMode.isUnmutedAll,
            uxTypeName: spaceView.uxType.name,
            allNotificationsUnmuted: spaceView.pushNotificationMode.isUnmutedAll,
            lastMessage: lastMessage,
            unreadCounter: preview.unreadCounter,
            mentionCounter: preview.mentionCounter,
            hasCounters: preview.hasCounters,
            wallpaper: wallpapers[spaceView.targetSpaceId] ?? .default
        )
    }
}

extension Container {
    var spaceCardModelBuilder: Factory< any SpaceCardModelBuilderProtocol> {
        self { SpaceCardModelBuilder() }.shared
    }
}
