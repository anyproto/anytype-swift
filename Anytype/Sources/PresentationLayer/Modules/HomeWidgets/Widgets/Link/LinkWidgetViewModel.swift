import Foundation
import Services
import AnytypeCore
import Factory


@MainActor
@Observable
final class LinkWidgetViewModel {

    // MARK: - DI

    @ObservationIgnored
    private let widgetBlockId: String
    @ObservationIgnored
    private let widgetObject: any BaseDocumentProtocol
    @ObservationIgnored
    private weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    // MARK: - State

    @ObservationIgnored
    private var linkedObjectDetails: ObjectDetails?
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []

    private(set) var name = ""
    private(set) var icon: Icon?
    private(set) var badgeModel: MessagePreviewModel?
    var dragId: String? { widgetBlockId }
    /// Tracks whether the current participant may remove channel pins. Owner-only
    /// today (middleware has no Admin role — plan Context). Drives the
    /// `.channelPin(isPinned: true)` menu item in `WidgetContainerView`.
    /// Single-predicate structure so a future Admin role widens this in one spot.
    var canManageChannelPins: Bool = false

    @ObservationIgnored
    private let dateFormatter = ChatPreviewDateFormatter()

    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.widgetObject
        self.output = data.output
    }
    
    func onHeaderTap() {
        guard let linkedObjectDetails else { return }
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(
            source: .object(type: linkedObjectDetails.analyticsType),
            createType: info.widgetCreateType
        )
        output?.onObjectSelected(screenData: linkedObjectDetails.screenData())
    }
    
    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscriptions()
        async let chatPreviewsSub: () = startChatPreviewsSubscription()
        async let permissionSub: () = startPermissionSubscription()

        _ = await (detailsSub, chatPreviewsSub, permissionSub)
    }

    // Drives `canManageChannelPins` from the current participant's permissions.
    // Owner-only today; single-predicate gate ready to widen if middleware adds an
    // Admin role later (plan Context / Task 13 final gating).
    private func startPermissionSubscription() async {
        let spaceId = widgetObject.spaceId
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let next = participantSpaceView.isOwner
            guard canManageChannelPins != next else { continue }
            canManageChannelPins = next
        }
    }
    
    // MARK: - Private
    
    private func startDetailsSubscriptions() async {
        for await details in widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            linkedObjectDetails = details
            name = details.pluralTitle
            icon = details.objectIconImage
            updateBadgeModel()
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            chatPreviews = previews
            updateBadgeModel()
        }
    }

    private func updateBadgeModel() {
        guard let linkedObjectDetails else {
            badgeModel = nil
            return
        }

        guard let chatPreview = chatPreviews.first(where: { $0.chatId == linkedObjectDetails.id }),
              let lastMessage = chatPreview.lastMessage else {
            badgeModel = nil
            return
        }

        let attachments = lastMessage.attachments.prefix(3).map { objectDetails in
            MessagePreviewModel.Attachment(
                id: objectDetails.id,
                icon: objectDetails.objectIconImage
            )
        }

        let spaceView = spaceViewsStorage.spaceView(spaceId: linkedObjectDetails.spaceId)
        let notificationMode = spaceView?.effectiveNotificationMode(for: linkedObjectDetails.id) ?? .all

        badgeModel = MessagePreviewModel(
            creatorTitle: lastMessage.creator?.title,
            text: lastMessage.text,
            attachments: Array(attachments),
            localizedAttachmentsText: lastMessage.localizedAttachmentsText,
            chatPreviewDate: dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true),
            unreadCounter: chatPreview.unreadCounter,
            mentionCounter: chatPreview.mentionCounter,
            hasUnreadReactions: chatPreview.hasUnreadReactions,
            notificationMode: notificationMode,
            chatName: nil
        )
    }
}
