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
    let channelWidgetsObject: any BaseDocumentProtocol
    // `nil` when the personalFavorites flag is off.
    @ObservationIgnored
    let personalWidgetsObject: (any BaseDocumentProtocol)?
    @ObservationIgnored
    private let spaceId: String
    // `nil` for library widgets (Pinned / Recent / …).
    let targetObjectId: String?
    weak var output: (any CommonWidgetModuleOutput)?

    @ObservationIgnored
    private let expandedService: any ExpandedServiceProtocol
    @ObservationIgnored
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol

    // MARK: - State

    var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    var homeState: HomeWidgetsState = .readonly
    var toastData: ToastBarData?
    @ObservationIgnored
    private let baseMenuItems: [WidgetMenuItem]
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

    private var isFavorited: Bool {
        guard let personalWidgetsObject, let targetObjectId else { return false }
        return personalWidgetsObject.containsWidgetFor(objectId: targetObjectId)
    }
    private var isPinnedToChannel: Bool {
        guard let targetObjectId else { return false }
        return channelWidgetsObject.containsWidgetFor(objectId: targetObjectId)
    }
    private var canManageChannelPins: Bool {
        guard FeatureFlags.personalFavorites, targetObjectId != nil else { return false }
        return participantSpacesStorage
            .participantSpaceView(spaceId: spaceId)?
            .canManageChannelPins ?? false
    }

    @ObservationIgnored
    private var isAutoExpanding = false

    init(
        widgetBlockId: String,
        channelWidgetsObject: some BaseDocumentProtocol,
        personalWidgetsObject: (any BaseDocumentProtocol)?,
        spaceId: String,
        expectedMenuItems: [WidgetMenuItem],
        defaultExpanded: Bool = true,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.channelWidgetsObject = channelWidgetsObject
        self.personalWidgetsObject = personalWidgetsObject
        self.spaceId = spaceId
        self.output = output

        expandedService = Container.shared.expandedService()
        isExpanded = expandedService.isExpanded(id: widgetBlockId, defaultValue: defaultExpanded)

        let widgetInfo = channelWidgetsObject.widgetInfo(blockId: widgetBlockId)
        let source = widgetInfo?.source

        if case let .object(details) = source {
            self.targetObjectId = details.id
        } else {
            self.targetObjectId = nil
        }

        let numberOfWidgetLayouts = source?.availableWidgetLayout.count ?? 0
        let menuItems = numberOfWidgetLayouts > 1 ? expectedMenuItems : expectedMenuItems.filter { $0 != .changeType }
        if source?.isLibrary ?? false {
            self.baseMenuItems = menuItems.filter { $0 != .remove }
        } else if FeatureFlags.personalFavorites {
            self.baseMenuItems = menuItems.filter { $0 != .remove && $0 != .removeSystemWidget }
        } else {
            self.baseMenuItems = menuItems.filter { $0 != .removeSystemWidget }
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
        if let info = channelWidgetsObject.widgetInfo(blockId: widgetBlockId) {
            if isExpanded {
                AnytypeAnalytics.instance().logOpenSidebarGroupToggle(source: info.source.analyticsSource)
            } else {
                AnytypeAnalytics.instance().logCloseSidebarGroupToggle(source: info.source.analyticsSource)
            }
        }
        expandedService.setState(id: widgetBlockId, isExpanded: isExpanded)
    }
}
