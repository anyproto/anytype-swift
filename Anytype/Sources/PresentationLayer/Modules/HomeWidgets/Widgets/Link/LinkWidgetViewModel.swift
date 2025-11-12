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
    
    private var subscriptions = [AnyCancellable]()
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
        setupAllSubscriptions()
        startChatPreviewsSubscription()
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
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        
        widgetObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId)
            .receiveOnMain()
            .sink { [weak self] details in
                self?.linkedObjectDetails = details
                self?.name = details.pluralTitle
                self?.icon = details.objectIconImage
                self?.updateBadgeModel()
            }
            .store(in: &subscriptions)
    }

    private func startChatPreviewsSubscription() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            for await previews in await chatMessagesPreviewsStorage.previewsSequence {
                self.chatPreviews = previews
                self.updateBadgeModel()
            }
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
            isMuted: isMuted
        )
    }
}
