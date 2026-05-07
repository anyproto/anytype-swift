import Foundation
import Services
import AnytypeCore

@MainActor
@Observable
final class PinnedSectionViewModel {

    // MARK: - DI

    @ObservationIgnored
    let info: AccountInfo
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol
    @ObservationIgnored
    let personalWidgetsObject: any BaseDocumentProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?

    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.homeWidgetsRecentStateManager)
    private var recentStateManager: any HomeWidgetsRecentStateManagerProtocol
    @ObservationIgnored
    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol

    // MARK: - State

    var widgetBlocks: [BlockWidgetInfo] = []
    var widgetsDataLoaded: Bool = false
    var homeState: HomeWidgetsState = .readonly

    init(
        info: AccountInfo,
        channelWidgetsObject: any BaseDocumentProtocol,
        personalWidgetsObject: any BaseDocumentProtocol,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.output = output
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let canEditSub: () = startCanEditSubscription()
        _ = await (widgetObjectSub, canEditSub)
    }

    private func startWidgetObjectTask() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            widgetsDataLoaded = true

            let blocks = channelWidgetsObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: channelWidgetsObject)

            let newWidgetBlocks = blocks
                .compactMap { channelWidgetsObject.widgetInfo(block: $0) }

            guard widgetBlocks != newWidgetBlocks else { continue }

            widgetBlocks = newWidgetBlocks
        }
    }

    private func startCanEditSubscription() async {
        for await canEdit in participantsStorage.canEditSequence(spaceId: info.accountSpaceId) {
            homeState = canEdit ? .readwrite : .readonly
        }
    }

    // MARK: - Drag-and-drop

    func widgetsDropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
    }

    func widgetsDropFinish(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        AnytypeAnalytics.instance().logReorderWidget(source: from.data.source.analyticsSource)
        Task {
            try? await objectActionService.move(
                dashboadId: channelWidgetsObject.objectId,
                blockId: from.data.id,
                dropPositionblockId: to.data.id,
                position: to.index > from.index ? .bottom : .top
            )
        }
    }
}
