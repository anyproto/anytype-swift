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
    
    private let blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol
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
    @Published var toastData = ToastBarData.empty
    
    init(
        widgetBlockId: String,
        widgetObject: some BaseDocumentProtocol,
        output: (any CommonWidgetModuleOutput)?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.output = output
        
        blockWidgetExpandedService = Container.shared.blockWidgetExpandedService.resolve()
        
        isExpanded = blockWidgetExpandedService.isExpanded(widgetBlockId: widgetBlockId)
    }
    
    // MARK: - Actions
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: widgetObject,
            widgetBlockId: widgetBlockId,
            homeState: homeState
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
        blockWidgetExpandedService.setState(widgetBlockId: widgetBlockId, isExpanded: isExpanded)
    }
}
