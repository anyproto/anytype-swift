import Foundation
import AnytypeCore
import Services
import Combine
import SwiftUI

@MainActor
@Observable
final class HomeWidgetsViewModel {

    // MARK: - DI

    let info: AccountInfo

    @Injected(\.documentsProvider) @ObservationIgnored
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.homeSectionsStorage) @ObservationIgnored
    private var homeSectionsStorage: any HomeSectionsStorageProtocol
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.expandedService) @ObservationIgnored
    private var expandedService: any ExpandedServiceProtocol
    @Injected(\.setSubscriptionDataBuilder) @ObservationIgnored
    private var setSubscriptionDataBuilder: any SetSubscriptionDataBuilderProtocol
    @Injected(\.subscriptionStorageProvider) @ObservationIgnored
    private var subscriptionStorageProvider: any SubscriptionStorageProviderProtocol
    @Injected(\.spaceViewsStorage) @ObservationIgnored
    private var spaceViewsStorage: any SpaceViewsStorageProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?

    // MARK: - State

    var homeWidgetData: HomepageWidgetViewData?
    var sectionsConfiguration: HomeSectionsConfiguration = .default
    private(set) var channelWidgetsObject: (any BaseDocumentProtocol)?
    private(set) var personalWidgetsObject: (any BaseDocumentProtocol)?
    /// Pre-warmed Set/Type widget subscriptions keyed by widgetBlockId, populated in `openWidgetObjects`.
    /// Allows Set/Type widgets to render rows on first frame and avoids the mid-transition row pop.
    private(set) var prefetchedSetSubscriptions: [String: PrefetchedSetSubscription] = [:]

    // Default false so readonly users never see (and can never tap) the Bin's empty-bin
    // action before `canEdit` resolves. Editors briefly see no Bin section until then —
    // matches pre-refactor `homeState = .readonly` default and `PinnedSectionViewModel`.
    private var canEdit: Bool = false

    var spaceId: String { info.accountSpaceId }

    var visibleSections: [HomeSection] {
        canEdit
            ? sectionsConfiguration.visibleSections
            : sectionsConfiguration.visibleSections.filter { $0 != .bin }
    }

    var hasUnreadSection: Bool {
        sectionsConfiguration.visibleSections.contains(.unread)
    }

    init(
        info: AccountInfo,
        output: (any HomeWidgetsModuleOutput)?
    ) {
        self.info = info
        self.output = output
    }

    func openWidgetObjects() async {
        let channel = documentsProvider.document(
            objectId: info.widgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )
        let personal = documentsProvider.document(
            objectId: info.personalWidgetsId,
            spaceId: info.accountSpaceId,
            mode: .handling
        )

        await withTaskGroup(of: Void.self) { group in
            group.addTask { try? await channel.open() }
            group.addTask { try? await personal.open() }
        }

        guard !Task.isCancelled else { return }

        // Pre-warm Set/Type widget subscriptions before flipping the section gate.
        // Rows are ready on first frame — no mid-transition row-pop jump. Runs in
        // every context (slide-in and overlay) because a visible jump is worse
        // than a small loader delay regardless of how the screen was presented.
        let prefetched = await prewarmSetWidgetSubscriptions(channelWidgetsObject: channel)

        guard !Task.isCancelled else { return }
        channelWidgetsObject = channel
        personalWidgetsObject = personal
        prefetchedSetSubscriptions = prefetched
    }

    func startSubscriptions() async {
        async let spaceViewTask: () = startSpaceViewTask()
        async let sectionsConfigurationTask: () = startSectionsConfigurationTask()
        async let canEditTask: () = startCanEditSubscription()

        _ = await (spaceViewTask, sectionsConfigurationTask, canEditTask)
    }

    func onAppear() {
        AnytypeAnalytics.instance().logScreenWidget()
    }

    func onSpaceSelected() {
        output?.onSpaceSelected()
    }

    func onMembersSelected(spaceId: String, route: SettingsSpaceShareRoute) {
        output?.onSpaceChatMembersSelected(spaceId: spaceId, route: route)
    }

    func onQrCodeSelected(url: URL) {
        output?.onSpaceChatShowQrCodeSelected(url: url)
    }

    func onManageSectionsSelected() {
        output?.onManageSectionsSelected()
    }

    // MARK: - Private

    private func startSectionsConfigurationTask() async {
        for await configuration in homeSectionsStorage.configurationPublisher(spaceId: info.accountSpaceId).values {
            sectionsConfiguration = configuration
        }
    }

    private func startCanEditSubscription() async {
        for await canEdit in accountParticipantStorage.canEditSequence(spaceId: info.accountSpaceId) {
            self.canEdit = canEdit
        }
    }

    private struct ObservedHomepage: Equatable {
        let objectId: String
        let canSetHomepage: Bool
    }

    private func startSpaceViewTask() async {
        var homepageTask: Task<Void, Never>?
        var lastObserved: ObservedHomepage?
        defer { homepageTask?.cancel() }

        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceId).values {
            let spaceView = participantSpaceView.spaceView

            // Home widget renders whichever object is set as homepage (Chat / Page / Collection).
            // 1-on-1 channels always home on Chat; `SpaceView.homepage` is unreliable there
            // (middleware may not populate it), so fall back to `info.spaceChatId`.
            let effectiveHomepage: SpaceHomepage = spaceView.isOneToOne && !info.spaceChatId.isEmpty
                ? .object(objectId: info.spaceChatId)
                : spaceView.homepage
            guard case let .object(objectId) = effectiveHomepage else {
                if lastObserved != nil {
                    homepageTask?.cancel()
                    homepageTask = nil
                    homeWidgetData = nil
                    lastObserved = nil
                }
                continue
            }

            // Only rebuild the observer when the observed tuple actually changes. Unrelated
            // SpaceView emissions (rename, member added, etc.) must not cancel the task or
            // clear homeWidgetData — doing so causes flicker/disappearance of the widget.
            let next = ObservedHomepage(objectId: objectId, canSetHomepage: participantSpaceView.canSetHomepage)
            guard lastObserved != next else { continue }

            // Subscribe to the homepage object's details so the widget hides upstream when the
            // object is archived, deleted, or fails to open. When details change (e.g. ownership
            // via canSetHomepage), re-emitting HomepageWidgetViewData propagates to the child.
            homepageTask?.cancel()
            // Clear stale data synchronously so a slow/failed `document.open()` for the new object
            // doesn't leave the previous homepage's widget visible and tappable.
            homeWidgetData = nil
            lastObserved = next
            homepageTask = Task { [weak self] in
                await self?.observeHomepageObject(objectId: next.objectId, canSetHomepage: next.canSetHomepage)
            }
        }
    }

    // MARK: - Set/Type widget pre-warm

    /// Maximum time we hold the gate waiting for any single widget's subscription
    /// to first-emit. If a widget exceeds this, that one widget falls back to today's
    /// behavior (header first, rows later) while the rest of the screen renders clean.
    private static let prewarmTimeout: TimeInterval = 0.6

    private func prewarmSetWidgetSubscriptions(
        channelWidgetsObject: any BaseDocumentProtocol
    ) async -> [String: PrefetchedSetSubscription] {
        let setWidgets = channelWidgetsObject.children
            .filter(\.isWidget)
            .compactMap { channelWidgetsObject.widgetInfo(block: $0) }
            .filter { Self.isSetTypeWidget(widgetInfo: $0) }
            .filter { expandedService.isExpanded(id: $0.id, defaultValue: true) }

        guard setWidgets.isNotEmpty else { return [:] }

        return await withTaskGroup(of: (String, PrefetchedSetSubscription)?.self) { group in
            for widgetInfo in setWidgets {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    guard let prefetched = await prewarmSingleSetWidget(widgetInfo: widgetInfo) else { return nil }
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

    /// Matches `HomeWidgetSubmoduleView`'s Set/Type routing: `.list`/`.type` objects shown
    /// as `.view` / `.list` / `.compactList` layouts. Tree widgets (`.tree` + `.page`) are
    /// not pre-warmed — their `ObjectSubscribeIds` already settles in single-digit ms.
    private static func isSetTypeWidget(widgetInfo: BlockWidgetInfo) -> Bool {
        guard case let .object(details) = widgetInfo.source else { return false }
        let validViewType = details.editorViewType == .list || details.editorViewType == .type
        let validLayout: [BlockWidget.Layout] = [.view, .list, .compactList]
        return validViewType && validLayout.contains(widgetInfo.fixedLayout)
    }

    private func prewarmSingleSetWidget(widgetInfo: BlockWidgetInfo) async -> PrefetchedSetSubscription? {
        guard case let .object(setDetails) = widgetInfo.source else { return nil }

        return await withTimeout(seconds: Self.prewarmTimeout) { [self] in
            let setDocument = documentsProvider.setDocument(
                objectId: setDetails.id,
                spaceId: info.accountSpaceId,
                mode: .preview
            )

            do { try await setDocument.open() } catch { return nil }

            // After `open()` returns, `setDocument.updateData()` runs on the next main-queue tick
            // (BaseDocument's `syncPublisher` replays `[.general]` via `receiveOnMain`). Subscribe
            // to `setUpdatePublisher` to catch that first `.dataviewUpdated` event; check the
            // populated state first in case it raced us.
            if !setDocument.dataView.views.isNotEmpty {
                for await update in setDocument.setUpdatePublisher.values {
                    if case .dataviewUpdated = update { break }
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

            // `statePublisher` is built from CurrentValueSubject, so a subscribe AFTER the
            // start-or-update call replays the current state synchronously through the filter.
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
        let identifier = "SetWidget-\(UUID().uuidString)"
        let spaceType = spaceViewsStorage.spaceView(spaceId: setDocument.spaceId)?.spaceType
        let setSubData = SetSubscriptionData(
            identifier: identifier,
            document: setDocument,
            groupFilter: nil,
            currentPage: 0,
            numberOfRowsPerPage: widgetInfo.fixedLimit,
            collectionId: setDocument.isCollection() ? setDocument.objectId : nil,
            objectOrderIds: setDocument.objectOrderIds(for: setSubscriptionDataBuilder.subscriptionId),
            spaceType: spaceType
        )
        return setSubscriptionDataBuilder.set(setSubData)
    }

    private func withTimeout<T: Sendable>(
        seconds: TimeInterval,
        operation: @escaping @MainActor () async -> T?
    ) async -> T? {
        await withTaskGroup(of: T?.self) { group in
            group.addTask { @MainActor in await operation() }
            group.addTask {
                try? await Task.sleep(for: .seconds(seconds))
                return nil
            }
            let first = await group.next() ?? nil
            group.cancelAll()
            return first
        }
    }

    private func observeHomepageObject(objectId: String, canSetHomepage: Bool) async {
        let document = documentsProvider.document(objectId: objectId, spaceId: spaceId, mode: .preview)
        try? await document.open()
        for await _ in document.syncPublisher.values {
            guard !Task.isCancelled else { return }
            let details = document.details
            if let details, !details.isArchivedOrDeleted {
                homeWidgetData = HomepageWidgetViewData(
                    spaceId: spaceId,
                    objectId: objectId,
                    canSetHomepage: canSetHomepage,
                    document: document,
                    output: output,
                    onChangeHome: { [weak self] in
                        self?.output?.onChangeHome()
                    },
                    onHomeTap: { [weak self] screenData in
                        self?.output?.onHomeObjectSelected(screenData: screenData)
                    }
                )
            } else {
                homeWidgetData = nil
            }
        }
    }

}
