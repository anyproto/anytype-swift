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
    @Injected(\.chatDetailsStorage)
    private var chatDetailsStorage: any ChatDetailsStorageProtocol

    func build(
        from spaces: [ParticipantSpaceViewDataWithPreview],
        wallpapers: [String: SpaceWallpaperType]
    ) async -> [SpaceCardModel] {
        await Task.detached {
            var models = [SpaceCardModel]()
            for space in spaces {
                models.append(await self.buildModel(from: space, wallpapers: wallpapers))
            }
            return models
        }.value
    }

    private func buildModel(
        from spaceData: ParticipantSpaceViewDataWithPreview,
        wallpapers: [String: SpaceWallpaperType]
    ) async -> SpaceCardModel {
        let spaceView = spaceData.spaceView
        let latestPreview = spaceData.latestPreview

        let lastMessage: MessagePreviewModel?
        if let lastMessagePreview = latestPreview.lastMessage {
            let attachments = lastMessagePreview.attachments.prefix(3).map { objectDetails in
                MessagePreviewModel.Attachment(
                    id: objectDetails.id,
                    icon: objectDetails.objectIconImage
                )
            }

            let chatId = latestPreview.chatId
            let chatName = await chatDetailsStorage.chat(id: chatId)?.name.withPlaceholder

            lastMessage = MessagePreviewModel(
                creatorTitle: lastMessagePreview.creator?.title,
                text: lastMessagePreview.text,
                attachments: Array(attachments),
                localizedAttachmentsText: lastMessagePreview.localizedAttachmentsText,
                chatPreviewDate: chatPreviewDateFormatter.localizedDateString(for: lastMessagePreview.createdAt, showTodayTime: true),
                unreadCounter: 0, // unsupported in space hub
                mentionCounter: 0, // unsupported in space hub
                hasUnreadReactions: false, // unsupported in space hub
                notificationMode: .all, // unsupported in space hub
                chatName: chatName
            )
        } else {
            lastMessage = nil
        }

        let multichatCompactPreview: String?
        if !spaceView.isOneToOne {
            multichatCompactPreview = await buildMultichatCompactPreview(unreadPreviews: spaceData.unreadPreviews)
        } else {
            multichatCompactPreview = nil
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
            canBeDeleted: spaceData.space.canBeDeleted,
            canLeave: spaceData.space.canLeave,
            uxTypeName: spaceView.uxType.name,
            supportsMultiChats: !spaceView.isOneToOne,
            isOneToOne: spaceView.isOneToOne,
            currentNotificationMode: spaceView.pushNotificationMode,
            showsMessageAuthor: spaceView.uxType.showsMessageAuthor,
            lastMessage: lastMessage,
            unreadCounter: spaceData.totalUnreadCounter,
            mentionCounter: spaceData.totalMentionCounter,
            hasUnreadReactions: spaceData.hasUnreadReactions,
            unreadCounterStyle: spaceData.unreadCounterStyle,
            mentionCounterStyle: spaceData.mentionCounterStyle,
            reactionStyle: spaceData.reactionStyle,
            hasCounters: spaceData.hasCounters,
            multichatCompactPreview: multichatCompactPreview,
            wallpaper: wallpapers[spaceView.targetSpaceId] ?? .default
        )
    }
    private func buildMultichatCompactPreview(unreadPreviews: [ChatMessagePreview]) async -> String? {
        guard unreadPreviews.isNotEmpty else { return nil }

        let maxVisible = 3
        var names = [String]()
        for preview in unreadPreviews.prefix(maxVisible) {
            if let chatDetail = await chatDetailsStorage.chat(id: preview.chatId) {
                names.append(chatDetail.name.withPlaceholder)
            }
        }

        guard names.isNotEmpty else { return nil }

        let remaining = unreadPreviews.count - maxVisible
        if remaining > 0 {
            return names.joined(separator: ", ") + " +\(remaining)"
        } else {
            return names.joined(separator: ", ")
        }
    }
}

extension Container {
    var spaceCardModelBuilder: Factory< any SpaceCardModelBuilderProtocol> {
        self { SpaceCardModelBuilder() }.shared
    }
}
