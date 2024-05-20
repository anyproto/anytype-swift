import Foundation
import SwiftUI

protocol TreeWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class TreeWidgetModuleAssembly: TreeWidgetModuleAssemblyProtocol {
    
    init() {
    }
    
    // MARK: - TreeWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        return TreeWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            internalModel: internalModel,
            output: output
        ).eraseToAnyView()
    }
}
