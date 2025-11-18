import Foundation
import Combine
import Services
import AnytypeCore
import Factory


@MainActor
final class LinkWidgetViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private weak var output: (any CommonWidgetModuleOutput)?

    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    // MARK: - State
    
    private var linkedObjectDetails: ObjectDetails?
    private var chatPreviews: [ChatMessagePreview] = []

    @Published private(set) var name = ""
    @Published private(set) var icon: Icon?
    @Published private(set) var badgeModel: MessagePreviewModel?
    var dragId: String? { widgetBlockId }

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
        
        _ = await (detailsSub, chatPreviewsSub)
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
        let isMuted = !(spaceView?.effectiveNotificationMode(for: linkedObjectDetails.id).isUnmutedAll ?? true)

        badgeModel = MessagePreviewModel(
            creatorTitle: lastMessage.creator?.globalName,
            text: lastMessage.text,
            attachments: Array(attachments),
            localizedAttachmentsText: lastMessage.localizedAttachmentsText,
            chatPreviewDate: dateFormatter.localizedDateString(for: lastMessage.createdAt, showTodayTime: true),
            unreadCounter: chatPreview.unreadCounter,
            mentionCounter: chatPreview.mentionCounter,
            isMuted: isMuted,
            chatName: nil
        )
    }
}
