import Foundation
import Services
import UIKit
import AnytypeCore

@MainActor
protocol WidgetActionsViewCommonMenuProviderProtocol: AnyObject {
    func onDeleteWidgetTap(
        widgetObject: any BaseDocumentProtocol,
        widgetBlockId: String,
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
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
        homeState: HomeWidgetsState,
        output: (any CommonWidgetModuleOutput)?
    ) {
        guard let info = widgetObject.widgetInfo(blockId: widgetBlockId) else { return }
        
        if FeatureFlags.homeObjectTypeWidgets, info.source.isLibrary {
            let data = DeleteSystemWidgetConfirmationData(onConfirm: { [weak self] in
                self?.deleteWidget(widgetObject: widgetObject, info: info, homeState: homeState)
            })
            output?.showDeleteSystemWidgetAlert(data: data)
        } else {
            deleteWidget(widgetObject: widgetObject, info: info, homeState: homeState)
        }
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
    
    private func deleteWidget(
        widgetObject: any BaseDocumentProtocol,
        info: BlockWidgetInfo,
        homeState: HomeWidgetsState
    ) {
        AnytypeAnalytics.instance().logDeleteWidget(
            source: info.source.analyticsSource,
            context: homeState.analyticsWidgetContext,
            createType: info.widgetCreateType
        )
        
        Task {
            try? await blockWidgetService.removeWidgetBlock(
                contextId: widgetObject.objectId,
                widgetBlockId: info.id
            )
        }
        
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
