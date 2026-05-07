import Foundation
import SwiftUI
import Services
import AnytypeCore

@MainActor
@Observable
final class PinnedSectionViewModel {

    // MARK: - DI

    @ObservationIgnored
    let spaceId: String
    @ObservationIgnored
    let channelWidgetsObject: any BaseDocumentProtocol

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
    var homeState: HomeWidgetsState = .readonly

    init(
        spaceId: String,
        channelWidgetsObject: any BaseDocumentProtocol
    ) {
        self.spaceId = spaceId
        self.channelWidgetsObject = channelWidgetsObject
    }

    // MARK: - Subscriptions

    func startSubscriptions() async {
        async let widgetObjectSub: () = startWidgetObjectTask()
        async let canEditSub: () = startCanEditSubscription()
        _ = await (widgetObjectSub, canEditSub)
    }

    private func startWidgetObjectTask() async {
        for await _ in channelWidgetsObject.syncPublisher.values {
            let blocks = channelWidgetsObject.children.filter(\.isWidget)
            recentStateManager.setupRecentStateIfNeeded(blocks: blocks, widgetObject: channelWidgetsObject)

            let newWidgetBlocks = blocks
                .compactMap { channelWidgetsObject.widgetInfo(block: $0) }

            guard widgetBlocks != newWidgetBlocks else { continue }

            withAnimation(.default) {
                widgetBlocks = newWidgetBlocks
            }
        }
    }

    private func startCanEditSubscription() async {
        for await canEdit in participantsStorage.canEditSequence(spaceId: spaceId) {
            homeState = canEdit ? .readwrite : .readonly
        }
    }

    // MARK: - Drag-and-drop

    func widgetsDropUpdate(from: DropDataElement<BlockWidgetInfo>, to: DropDataElement<BlockWidgetInfo>) {
        withAnimation(.default) {
            widgetBlocks.move(fromOffsets: IndexSet(integer: from.index), toOffset: to.index)
        }
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
