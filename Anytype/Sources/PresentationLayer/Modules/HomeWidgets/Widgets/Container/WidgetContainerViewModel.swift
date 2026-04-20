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
    /// derive `personalWidgetsId`. All current call sites forward
    /// `WidgetSubmoduleData.spaceInfo` here.
    let spaceInfo: AccountInfo
    /// Target object id referenced by this widget block. Populated for `.object`
    /// sources (channel pins / personal favorites) and `nil` for library widgets
    /// (Pinned / Recent / etc.). Needed by the new `.favorite` / `.channelPin`
    /// menu items in Task 10 so the provider can toggle state for the right object.
    let targetObjectId: String?
    weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    private let expandedService: any ExpandedServiceProtocol
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
    /// Source-filtered items fixed at init — `.changeType` / `.removeSystemWidget`
    /// inclusion depends only on widget source. Runtime items (`.favorite`,
    /// `.channelPin`) are appended by the computed `menuItems` below.
    @ObservationIgnored
    private let baseMenuItems: [WidgetMenuItem]
    /// Final menu items for the long-press context menu. Evaluated lazily each time
    /// SwiftUI builds the `.contextMenu` closure (i.e. on long-press), so the
    /// per-item state is read synchronously from live documents without needing
    /// persistent subscriptions.
    var menuItems: [WidgetMenuItem] {
        guard FeatureFlags.personalFavorites, targetObjectId != nil else {
            return baseMenuItems
        }
        var extras: [WidgetMenuItem] = [.favorite(isFavorited: isFavorited)]
        if canManageChannelPins {
            extras.append(.channelPin(isPinned: isPinnedToChannel))
        }
        return baseMenuItems + extras
    }

    /// Whether `targetObjectId` currently lives in the per-user personal widgets
    /// document. Read on demand from the already-open doc; stale-while-menu-open is
    /// acceptable since the menu is re-evaluated on every long-press.
    private var isFavorited: Bool {
        guard let personalWidgetsObject, let targetObjectId else { return false }
        return personalWidgetsObject.isInMyFavorites(objectId: targetObjectId)
    }
    /// Whether `targetObjectId` is currently present in the shared channel widgets
    /// document. Read on demand from `widgetObject` (which is the channel widgets
    /// doc for object-widget call sites).
    private var isPinnedToChannel: Bool {
        guard let targetObjectId else { return false }
        return widgetObject.isPinnedToChannel(objectId: targetObjectId)
    }
    /// Gate for rendering `.channelPin`. Read on demand from the participant-space
    /// storage snapshot.
    private var canManageChannelPins: Bool {
        guard FeatureFlags.personalFavorites, targetObjectId != nil else { return false }
        return participantSpacesStorage
            .participantSpaceView(spaceId: spaceInfo.accountSpaceId)?
            .canManageChannelPins ?? false
    }

    @ObservationIgnored
    private var isAutoExpanding = false

    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        spaceInfo: AccountInfo,
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
        // `.removeSystemWidget` is only for library widgets (Bin, Objects, Tasks, …).
        // Object widgets get channel-pin toggling via `.channelPin`, appended by the
        // computed `menuItems` property below from live state + permissions.
        self.baseMenuItems = (source?.isLibrary ?? false) ? menuItems : menuItems.filter { $0 != .removeSystemWidget }

        // Resolve the personal widgets doc once so `isFavorited` can read a snapshot
        // from it on demand. Flag-gated + targetObjectId-gated to keep byte-identical
        // behaviour when the feature is off or when this widget has no target (library).
        if FeatureFlags.personalFavorites, targetObjectId != nil {
            self.personalWidgetsObject = documentService.document(
                objectId: spaceInfo.personalWidgetsId,
                spaceId: spaceInfo.accountSpaceId
            )
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
