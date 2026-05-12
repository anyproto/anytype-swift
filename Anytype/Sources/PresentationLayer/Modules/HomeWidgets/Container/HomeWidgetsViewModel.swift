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
    @Injected(\.widgetsObjectsStorage) @ObservationIgnored
    private var widgetsObjectsStorage: any WidgetsObjectsStorageProtocol
    @Injected(\.participantSpacesStorage) @ObservationIgnored
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.homeSectionsStorage) @ObservationIgnored
    private var homeSectionsStorage: any HomeSectionsStorageProtocol
    @Injected(\.participantsStorage) @ObservationIgnored
    private var accountParticipantStorage: any ParticipantsStorageProtocol
    @Injected(\.setWidgetsPrewarmer) @ObservationIgnored
    private var setWidgetsPrewarmer: any SetWidgetsPrewarmerProtocol
    @Injected(\.treeWidgetsPrewarmer) @ObservationIgnored
    private var treeWidgetsPrewarmer: any TreeWidgetsPrewarmerProtocol
    @Injected(\.unreadSectionPrewarmer) @ObservationIgnored
    private var unreadSectionPrewarmer: any UnreadSectionPrewarmerProtocol

    @ObservationIgnored
    weak var output: (any HomeWidgetsModuleOutput)?

    // MARK: - State

    var homeWidgetData: HomepageWidgetViewData?
    var sectionsConfiguration: HomeSectionsConfiguration = .default
    private(set) var channelWidgetsObject: (any BaseDocumentProtocol)?
    private(set) var personalWidgetsObject: (any BaseDocumentProtocol)?
    private(set) var prefetchedSetSubscriptions: [String: PrefetchedSetSubscription] = [:]
    private(set) var prefetchedTreeChildren: [String: PrefetchedTreeChildren] = [:]
    private(set) var prefetchedUnreadSection: PrefetchedUnreadSection?

    // Default false so readonly users never see (and can never tap) the Bin's empty-bin
    // action before `canEdit` resolves. Editors briefly see no Bin section until then —
    // matches pre-refactor `homeState = .readonly` default and `PinnedSectionViewModel`.
    private var canEdit: Bool = false

    @ObservationIgnored
    private var prewarmTask: Task<Void, Never>?

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
        // Spawn pre-warm in init so it overlaps the space-transition animation,
        // not from `.task` on view appear. Observation propagates the Prefetched*
        // results to the view once `runPrewarm` populates state.
        prewarmTask = Task(priority: .high) { [weak self] in
            await self?.runPrewarm()
        }
    }

    deinit {
        prewarmTask?.cancel()
    }

    /// Test synchronization hook — awaits the init-spawned pre-warm Task.
    /// Not called from production code; the view reads state via Observation.
    func awaitPrewarm() async {
        await prewarmTask?.value
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

    private func runPrewarm() async {
        // Docs may still be opening (kicked off upstream in ActiveSpaceManager);
        // wait so prewarm sees a live channel doc.
        await widgetsObjectsStorage.waitForReady(spaceId: info.accountSpaceId)
        guard !Task.isCancelled,
              let (channel, personal) = widgetsObjectsStorage.widgetsObjects(spaceId: info.accountSpaceId)
        else { return }

        // Pre-warm before flipping the section gate so Set/Type and expanded Tree
        // widgets render rows on the first frame. The view body guards on
        // `channelWidgetsObject != nil`; Observation re-renders once we assign below.
        async let prefetchedSet = setWidgetsPrewarmer.prewarm(channelDoc: channel, spaceId: info.accountSpaceId)
        async let prefetchedTree = treeWidgetsPrewarmer.prewarm(channelDoc: channel, spaceId: info.accountSpaceId)
        async let prefetchedUnread = unreadSectionPrewarmer.prewarm(spaceId: info.accountSpaceId)
        let (setMap, treeMap, unread) = await (prefetchedSet, prefetchedTree, prefetchedUnread)

        guard !Task.isCancelled else { return }
        channelWidgetsObject = channel
        personalWidgetsObject = personal
        prefetchedSetSubscriptions = setMap
        prefetchedTreeChildren = treeMap
        prefetchedUnreadSection = unread
    }

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
