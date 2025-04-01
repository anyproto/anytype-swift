import Foundation
import Services
import UIKit

@MainActor
protocol WidgetActionsViewCommonMenuProviderProtocol: AnyObject {
    func onDeleteWidgetTap(
        widgetObject: any BaseDocumentProtocol,
        widgetBlockId: String,
        homeState: HomeWidgetsState
    )
    
    func onChangeTypeTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    )
    
    func onAddBelowTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    )
}

@MainActor
final class WidgetActionsViewCommonMenuProvider: WidgetActionsViewCommonMenuProviderProtocol {
    
    @Injected(\.blockWidgetService)
    private var blockWidgetService: any BlockWidgetServiceProtocol
    
    nonisolated init() {}
    
    func onDeleteWidgetTap(
        widgetObject: any BaseDocumentProtocol,
        widgetBlockId: String,
        homeState: HomeWidgetsState
    ) {
        if let info = widgetObject.widgetInfo(blockId: widgetBlockId) {
            AnytypeAnalytics.instance().logDeleteWidget(
                source: info.source.analyticsSource,
                context: homeState.analyticsWidgetContext,
                createType: info.widgetCreateType
            )
        }
        
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: widgetBlockId
            )
        }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onChangeTypeTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    ) {
        output?.onChangeWidgetType(widgetId: widgetBlockId, context: homeState.analyticsWidgetContext)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    func onAddBelowTap(
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    ) {
        AnytypeAnalytics.instance().logClickAddWidget(context: homeState.analyticsWidgetContext)
        output?.onAddBelowWidget(widgetId: widgetBlockId, context: homeState.analyticsWidgetContext)
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
