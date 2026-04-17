import Foundation
import Services
import UIKit
import AnytypeCore
import SwiftUI

@MainActor
@Observable
final class WidgetContainerViewModel {

    // MARK: - DI

    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    /// Per-space account info — needed by the new `.favorite` menu items to
    /// derive `personalWidgetsId`. `nil` for legacy call sites (e.g. Home widget)
    /// that pre-date the personal favorites feature.
    let spaceInfo: AccountInfo?
    /// Target object id referenced by this widget block. Populated for `.object`
    /// sources (channel pins / personal favorites) and `nil` for library widgets
    /// (Pinned / Recent / etc.). Needed by the new `.favorite` / `.channelPin`
    /// menu items in Task 10 so the provider can toggle state for the right object.
    let targetObjectId: String?
    weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    private let expandedService: any ExpandedServiceProtocol
    @ObservationIgnored
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @ObservationIgnored
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @ObservationIgnored
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @ObservationIgnored
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @ObservationIgnored
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()
    @ObservationIgnored
    private var personalWidgetsObject: (any BaseDocumentProtocol)?

    // MARK: - State

    var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    var homeState: HomeWidgetsState = .readonly
    var toastData: ToastBarData?
    let menuItems: [WidgetMenuItem]
    /// Tracks whether `targetObjectId` currently lives in the per-user personal
    /// widgets document. Drives the Favorite / Unfavorite label + icon in the
    /// long-press menu. Updated reactively from `personalWidgetsObject.syncPublisher`.
    var isFavorited: Bool = false
    /// Tracks whether `targetObjectId` is currently present in the shared channel
    /// widgets document. Drives the Pin-to-Channel / Unpin-from-Channel label + icon
    /// in the long-press menu. Reactive so a concurrent cross-device remove doesn't
    /// cause a stale "Unpin" tap to re-pin.
    var isPinnedToChannel: Bool = false
    /// Gate for rendering the Pin-to-Channel / Unpin-from-Channel menu item.
    /// Read off the current participant's role via `ParticipantSpaceViewData.canManageChannelPins`.
    var canManageChannelPins: Bool = false

    @ObservationIgnored
    private var isAutoExpanding = false

    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        spaceInfo: AccountInfo?,
        expectedMenuItems: [WidgetMenuItem],
        defaultExpanded: Bool = true,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.spaceInfo = spaceInfo
        self.output = output

        expandedService = Container.shared.expandedService()
        isExpanded = expandedService.isExpanded(id: widgetBlockId, defaultValue: defaultExpanded)

        let widgetInfo = widgetObject.widgetInfo(blockId: widgetBlockId)
        let source = widgetInfo?.source

        if case let .object(details) = source {
            self.targetObjectId = details.id
        } else {
            self.targetObjectId = nil
        }

        let numberOfWidgetLayouts = source?.availableWidgetLayout.count ?? 0
        let menuItems = numberOfWidgetLayouts > 1 ? expectedMenuItems : expectedMenuItems.filter { $0 != .changeType }
        self.menuItems = (source?.isLibrary ?? false) ? menuItems.filter { $0 != .remove } : menuItems.filter { $0 != .removeSystemWidget }

        // Resolve the personal widgets doc once so `startFavoriteSubscription()` can
        // observe it. Flag-gated to keep byte-identical behaviour when the feature
        // is off — no document is opened and no subscription fires.
        if FeatureFlags.personalFavorites, let spaceInfo, targetObjectId != nil {
            self.personalWidgetsObject = documentService.document(
                objectId: spaceInfo.personalWidgetsId,
                spaceId: spaceInfo.accountSpaceId
            )
        }
    }

    // MARK: - Subscriptions

    /// Keeps `isFavorited` in sync with the personal widgets virtual document so the
    /// long-press menu label / icon flip the moment a favorite is added or removed
    /// elsewhere (another menu, another device via CRDT, etc.).
    func startFavoriteSubscription() async {
        guard let personalWidgetsObject, let targetObjectId else { return }
        for await _ in personalWidgetsObject.syncPublisher.values {
            let next = personalWidgetsObject.isInMyFavorites(objectId: targetObjectId)
            guard isFavorited != next else { continue }
            isFavorited = next
        }
    }

    /// Keeps `isPinnedToChannel` in sync with the shared channel widgets document so
    /// an Unpin tap never races a concurrent cross-device remove.
    func startChannelPinSubscription() async {
        guard let targetObjectId else { return }
        for await _ in widgetObject.syncPublisher.values {
            let next = widgetObject.isPinnedToChannel(objectId: targetObjectId)
            guard isPinnedToChannel != next else { continue }
            isPinnedToChannel = next
        }
    }

    /// Keeps `canManageChannelPins` in sync with the current participant's role so
    /// Tree/List/Set widgets surface the same Pin-to-Channel menu item as LinkWidget.
    /// Guarded by flag + targetObjectId to keep the subscription dormant otherwise.
    func startPermissionSubscription() async {
        guard FeatureFlags.personalFavorites, let spaceInfo, targetObjectId != nil else { return }
        for await participantSpaceView in participantSpacesStorage.participantSpaceViewPublisher(spaceId: spaceInfo.accountSpaceId).values {
            let next = participantSpaceView.canManageChannelPins
            guard canManageChannelPins != next else { continue }
            canManageChannelPins = next
        }
    }
    
    func updateExpanded(contentState: WidgetContentState, animated: Bool = true) {
        guard contentState != .loading else { return }
        guard !expandedService.hasUserOverride(id: widgetBlockId) else { return }
        let shouldExpand = contentState == .hasData
        isAutoExpanding = true
        if animated {
            withAnimation {
                isExpanded = shouldExpand
            }
        } else {
            isExpanded = shouldExpand
        }
        isAutoExpanding = false
    }

    // MARK: - Private

    private func expandedDidChange() {
        guard !isAutoExpanding else { return }
        UISelectionFeedbackGenerator().selectionChanged()
        if let info = widgetObject.widgetInfo(blockId: widgetBlockId) {
            if isExpanded {
                AnytypeAnalytics.instance().logOpenSidebarGroupToggle(source: info.source.analyticsSource)
            } else {
                AnytypeAnalytics.instance().logCloseSidebarGroupToggle(source: info.source.analyticsSource)
            }
        }
        expandedService.setState(id: widgetBlockId, isExpanded: isExpanded)
    }
}
