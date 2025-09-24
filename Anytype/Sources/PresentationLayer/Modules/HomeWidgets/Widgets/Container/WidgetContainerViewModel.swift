import Foundation
import Combine
import Services
import UIKit
import AnytypeCore
import SwiftUI

@MainActor
final class WidgetContainerViewModel: ObservableObject {
    
    // MARK: - DI
    
    let widgetBlockId: String
    let widgetObject: any BaseDocumentProtocol
    weak var output: (any CommonWidgetModuleOutput)?
    
    private let expandedService: any ExpandedServiceProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    
    // MARK: - State
    
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var toastData: ToastBarData?
    let menuItems: [WidgetMenuItem]
    
    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        expectedMenuItems: [WidgetMenuItem],
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.output = output
        
        expandedService = Container.shared.expandedService()
        isExpanded = expandedService.isExpanded(id: widgetBlockId, defaultValue: true)
        
        let source = widgetObject.widgetInfo(blockId: widgetBlockId)?.source
        
        let numberOfWidgetLayouts = source?.availableWidgetLayout.count ?? 0
        let menuItems = numberOfWidgetLayouts > 1 ? expectedMenuItems : expectedMenuItems.filter { $0 != .changeType }
        if FeatureFlags.homeObjectTypeWidgets {
            self.menuItems = (source?.isLibrary ?? false) ? menuItems.filter { $0 != .remove } : menuItems.filter { $0 != .removeSystemWidget }
        } else {
            self.menuItems = menuItems
        }
    }
    
    // MARK: - Actions
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: widgetObject,
            widgetBlockId: widgetBlockId,
            homeState: homeState,
            output: output
        )
    }
    
    func onEditTap() {
        AnytypeAnalytics.instance().logEditWidget()
        homeState = .editWidgets
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    // MARK: - Private
    
    private func expandedDidChange() {
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
