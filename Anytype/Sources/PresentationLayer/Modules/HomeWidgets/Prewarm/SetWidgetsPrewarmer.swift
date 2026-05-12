import Foundation
import Services
import AnytypeCore

@MainActor
protocol SetWidgetsPrewarmerProtocol: AnyObject, Sendable {
    func prewarm(channelDoc: any BaseDocumentProtocol) async -> [String: PrefetchedSetSubscription]
}

@MainActor
final class SetWidgetsPrewarmer: SetWidgetsPrewarmerProtocol {

    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.setSubscriptionDataBuilder)
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.spaceViewsStorage)
    private var spaceViewsStorage: any SpaceViewsStorageProtocol
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol

    /// Per-widget budget. A slow widget falls back to its own mount-time open
    /// (header first, rows later) instead of stalling the whole gate.
    private static let prewarmTimeout: TimeInterval = 0.6

    nonisolated init() {}

    func prewarm(channelDoc: any BaseDocumentProtocol) async -> [String: PrefetchedSetSubscription] {
        let spaceId = channelDoc.spaceId
        let setWidgets = channelDoc.children.compactMap { child -> BlockWidgetInfo? in
            guard child.isWidget,
                  let info = channelDoc.widgetInfo(block: child),
                  info.isSetTypeWidget,
                  expandedService.isExpanded(id: info.id, defaultValue: true)
            else { return nil }
            return info
        }

        guard setWidgets.isNotEmpty else { return [:] }

        return await withTaskGroup(of: (String, PrefetchedSetSubscription)?.self) { group in
            for widgetInfo in setWidgets {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    guard let prefetched = await prewarmSingleSetWidget(
                        widgetInfo: widgetInfo,
                        spaceId: spaceId
                    ) else { return nil }
                    return (widgetInfo.id, prefetched)
                }
            }

            var result: [String: PrefetchedSetSubscription] = [:]
            for await pair in group {
                if let (id, prefetched) = pair {
                    result[id] = prefetched
                }
            }
            return result
        }
    }

    private func prewarmSingleSetWidget(
        widgetInfo: BlockWidgetInfo,
        spaceId: String
    ) async -> PrefetchedSetSubscription? {
        guard case let .object(setDetails) = widgetInfo.source else { return nil }

        return await withPrewarmTimeout(seconds: Self.prewarmTimeout) { [self] in
            let setDocument = documentsProvider.setDocument(
                objectId: setDetails.id,
                spaceId: spaceId,
                mode: .preview
            )

            do { try await setDocument.open() } catch { return nil }

            // `setDocument.updateData()` runs on the next main-queue tick after open()
            // returns (syncPublisher replays via `receiveOnMain`). Check the actual
            // state on every emission — `setUpdatePublisher` can emit `.syncStatus`
            // before `.dataviewUpdated`, and we'd loop without progress if we only
            // matched on the event variant.
            if !setDocument.dataView.views.isNotEmpty {
                for await _ in setDocument.setUpdatePublisher.values {
                    if setDocument.dataView.views.isNotEmpty { break }
                }
            }

            guard setDocument.canStartSubscription(), setDocument.dataView.views.isNotEmpty else {
                return nil
            }

            let subscriptionData = buildSubscriptionData(
                widgetInfo: widgetInfo,
                setDocument: setDocument
            )

            let storage = subscriptionStorageProvider.createSubscriptionStorage(
                subId: subscriptionData.identifier
            )
            do {
                try await storage.startOrUpdateSubscription(data: subscriptionData)
            } catch {
                return nil
            }

            // `statePublisher` is backed by CurrentValueSubject, so subscribing after
            // `startOrUpdateSubscription` returns replays the current state immediately.
            for await state in storage.statePublisher.values {
                return PrefetchedSetSubscription(
                    setDocument: setDocument,
                    subscriptionStorage: storage,
                    state: state
                )
            }
            return nil
        }
    }

    private func buildSubscriptionData(
        widgetInfo: BlockWidgetInfo,
        setDocument: any SetDocumentProtocol
    ) -> SubscriptionData {
        setSubscriptionDataBuilder.widgetSubscriptionData(
            widgetInfo: widgetInfo,
            setDocument: setDocument,
            identifier: "SetWidget-\(UUID().uuidString)",
            spaceType: spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)?.spaceType
        )
    }
}
