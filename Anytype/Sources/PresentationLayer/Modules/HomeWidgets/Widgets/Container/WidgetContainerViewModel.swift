import Foundation
import Combine
import Services
import UIKit
import AnytypeCore
import SwiftUI

@MainActor
final class WidgetContainerViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let widgetBlockId: String
    private let widgetObject: any BaseDocumentProtocol
    private weak var output: (any CommonWidgetModuleOutput)?
    
    private let blockWidgetExpandedService: any BlockWidgetExpandedServiceProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    
    
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
        if let info = widgetObject.widgetInfo(blockId: widgetBlockId) {
            AnytypeAnalytics.instance().logDeleteWidget(source: info.source.analyticsSource, context: analyticsContext())
        }
        
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onEditTap() {
        AnytypeAnalytics.instance().logEditWidget()
        homeState = .editWidgets
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onChangeTypeTap() {
        output?.onChangeWidgetType(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onAddBelowTap() {
        AnytypeAnalytics.instance().logClickAddWidget(context: analyticsContext())
        output?.onAddBelowWidget(widgetId: widgetBlockId, context: analyticsContext())
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
    
    private func analyticsContext() -> AnalyticsWidgetContext {
        return homeState.isEditWidgets ? .editor : .home
    }
}
