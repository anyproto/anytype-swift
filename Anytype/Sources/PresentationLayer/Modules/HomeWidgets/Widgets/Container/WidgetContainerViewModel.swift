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
    private let widgetObject: BaseDocumentProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    private let blockWidgetExpandedService: BlockWidgetExpandedServiceProtocol
    @Injected(\.blockWidgetService)
    private var blockWidgetService: BlockWidgetServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.searchService)
    private var searchService: SearchServiceProtocol
    
    
    // MARK: - State
    
    @Published var isExpanded: Bool {
        didSet { expandedDidChange() }
    }
    @Published var homeState: HomeWidgetsState = .readonly
    @Published var toastData = ToastBarData.empty
    
    init(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        output: CommonWidgetModuleOutput?
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
    
    func onChangeSourceTap() {
        output?.onChangeSource(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func onChangeTypeTap() {
        output?.onChangeWidgetType(widgetId: widgetBlockId, context: analyticsContext())
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onAddBelowTap() {
        AnytypeAnalytics.instance().logAddWidget(context: analyticsContext())
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
