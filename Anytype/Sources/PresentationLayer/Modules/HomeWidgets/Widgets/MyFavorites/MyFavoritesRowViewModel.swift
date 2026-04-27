import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class MyFavoritesRowViewModel {

    // MARK: - Construction context

    let widgetBlockId: String
    let spaceId: String
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
    let menuViewModel: MyFavoritesRowContextMenuViewModel

    @ObservationIgnored
    private let onObjectSelected: (ObjectDetails) -> Void

    var objectId: String { details.id }

    // MARK: - DI

    @ObservationIgnored
    @Injected(\.chatMessagesPreviewsStorage)
    private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol
    @ObservationIgnored
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @ObservationIgnored
    @Injected(\.widgetChatPreviewBuilder)
    private var chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol

    // MARK: - State

    @ObservationIgnored
    private var details: ObjectDetails
    @ObservationIgnored
    private var chatPreview: ChatMessagePreview?

    private(set) var title: String
    private(set) var icon: Icon?
    private(set) var badgeModel: MessagePreviewModel?

    init(
        widgetBlockId: String,
        details: ObjectDetails,
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        onObjectSelected: @escaping (ObjectDetails) -> Void
    ) {
        self.widgetBlockId = widgetBlockId
        self.details = details
        self.spaceId = spaceId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.onObjectSelected = onObjectSelected
        self.title = details.pluralTitle
        self.icon = details.objectIconImage
        self.menuViewModel = MyFavoritesRowContextMenuViewModel(
            objectId: details.id,
            spaceId: spaceId,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject
        )
    }

    func onTap() {
        onObjectSelected(details)
    }

    func startSubscriptions() async {
        async let detailsSub: () = startDetailsSubscription()
        async let chatPreviewsSub: () = startChatPreviewsSubscription()
        async let spaceViewSub: () = startSpaceViewSubscription()
        _ = await (detailsSub, chatPreviewsSub, spaceViewSub)
    }

    // MARK: - Private

    private func startDetailsSubscription() async {
        for await details in personalWidgetsObject.widgetTargetDetailsPublisher(widgetBlockId: widgetBlockId).values {
            self.details = details
            title = details.pluralTitle
            icon = details.objectIconImage
            updateBadgeModel()
        }
    }

    private func startChatPreviewsSubscription() async {
        for await previews in await chatMessagesPreviewsStorage.previewsSequence {
            let next = previews.first(where: { $0.chatId == objectId })
            guard chatPreview != next else { continue }
            chatPreview = next
            updateBadgeModel()
        }
    }

    private func startSpaceViewSubscription() async {
        for await _ in spaceViewsStorage.spaceViewPublisher(spaceId: spaceId).removeDuplicates().values {
            updateBadgeModel()
        }
    }

    private func updateBadgeModel() {
        let spaceView = spaceViewsStorage.spaceView(spaceId: spaceId)
        let next = chatPreview.flatMap {
            chatPreviewBuilder.build(chatPreview: $0, spaceView: spaceView)
        }
        guard badgeModel != next else { return }
        badgeModel = next
    }
}
