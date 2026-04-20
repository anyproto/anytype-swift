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
    @Injected(\.widgetChatPreviewBuilder)
    private var chatPreviewBuilder: any WidgetChatPreviewBuilderProtocol

    // MARK: - State

    @ObservationIgnored
    private var linkedObjectDetails: ObjectDetails?
    @ObservationIgnored
    private var chatPreviews: [ChatMessagePreview] = []

    private(set) var name = ""
    private(set) var icon: Icon?
    private(set) var badgeModel: MessagePreviewModel?
    var dragId: String? { widgetBlockId }

    init(data: WidgetSubmoduleData) {
        self.widgetBlockId = data.widgetBlockId
        self.widgetObject = data.channelWidgetsObject
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
        let spaceView = spaceViewsStorage.spaceView(spaceId: linkedObjectDetails.spaceId)
        badgeModel = chatPreviewBuilder.build(
            chatPreviews: chatPreviews,
            objectId: linkedObjectDetails.id,
            spaceView: spaceView
        )
    }
}
