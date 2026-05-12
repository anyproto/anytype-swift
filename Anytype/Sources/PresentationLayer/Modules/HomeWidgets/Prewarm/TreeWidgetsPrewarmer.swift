import Foundation
import Services
import AnytypeCore

@MainActor
protocol TreeWidgetsPrewarmerProtocol: AnyObject, Sendable {
    func prewarm(
        channelDoc: any BaseDocumentProtocol,
        spaceId: String
    ) async -> [String: PrefetchedTreeChildren]
}

@MainActor
final class TreeWidgetsPrewarmer: TreeWidgetsPrewarmerProtocol {

    @Injected(\.subscriptionStorageProvider)
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.expandedService)
    private var expandedService: any ExpandedServiceProtocol

    /// Per-widget budget. A slow widget falls back to its own mount-time open
    /// (header first, rows later) instead of stalling the whole gate.
    private static let prewarmTimeout: TimeInterval = 0.6

    nonisolated init() {}

    func prewarm(
        channelDoc: any BaseDocumentProtocol,
        spaceId: String
    ) async -> [String: PrefetchedTreeChildren] {
        let treeWidgets = channelDoc.children.compactMap { child -> BlockWidgetInfo? in
            guard child.isWidget,
                  let info = channelDoc.widgetInfo(block: child),
                  info.isTreeObjectWidget,
                  expandedService.isExpanded(id: info.id, defaultValue: true)
            else { return nil }
            return info
        }

        guard treeWidgets.isNotEmpty else { return [:] }

        return await withTaskGroup(of: (String, PrefetchedTreeChildren)?.self) { group in
            for widgetInfo in treeWidgets {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    guard let prefetched = await prewarmSingleTreeWidget(
                        widgetInfo: widgetInfo,
                        spaceId: spaceId
                    ) else { return nil }
                    return (widgetInfo.id, prefetched)
                }
            }

            var result: [String: PrefetchedTreeChildren] = [:]
            for await pair in group {
                if let (id, prefetched) = pair {
                    result[id] = prefetched
                }
            }
            return result
        }
    }

    private func prewarmSingleTreeWidget(
        widgetInfo: BlockWidgetInfo,
        spaceId: String
    ) async -> PrefetchedTreeChildren? {
        guard case let .object(linkedObjectDetails) = widgetInfo.source else { return nil }

        // Target has no children — seed an empty list so the widget renders `.empty`
        // synchronously on first frame instead of flashing `.loading` → `.empty`
        // when the live subscription emits its first (empty) result.
        guard linkedObjectDetails.links.isNotEmpty else {
            return PrefetchedTreeChildren(childDetails: [])
        }

        return await withPrewarmTimeout(seconds: Self.prewarmTimeout) { [self] in
            // Fresh builder per widget — its `subscriptionId` is the storage's `subId`,
            // and we need a unique pair so disposable storages don't collide.
            let builder = TreeSubscriptionDataBuilder()
            let storage = subscriptionStorageProvider.createSubscriptionStorage(
                subId: builder.subscriptionId
            )
            let subscriptionData = builder.build(
                spaceId: spaceId,
                objectIds: linkedObjectDetails.links
            )

            do {
                try await storage.startOrUpdateSubscription(data: subscriptionData)
            } catch {
                return nil
            }

            // `statePublisher` is backed by CurrentValueSubject, so subscribing after
            // `startOrUpdateSubscription` returns replays the current state immediately.
            var snapshot: [ObjectDetails]?
            for await state in storage.statePublisher.values {
                snapshot = state.items
                break
            }
            try? await storage.stopSubscription()

            guard let items = snapshot else { return nil }

            // Mirror `TreeSubscriptionManager`'s publisher composition: filter to
            // openable objects, sort by parent `.links` order, then apply the limit.
            let sorted = items
                .filter(\.isNotDeletedAndSupportedForOpening)
                .reordered(by: linkedObjectDetails.links, transform: { $0.id })
            return PrefetchedTreeChildren(childDetails: Array(sorted.prefix(widgetInfo.fixedLimit)))
        }
    }
}
