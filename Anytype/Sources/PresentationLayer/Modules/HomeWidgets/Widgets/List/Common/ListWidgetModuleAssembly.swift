import Foundation
import SwiftUI

protocol ListWidgetModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetDataviewInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView
}

final class ListWidgetModuleAssembly: ListWidgetModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - TreeWidgetModuleAssemblyProtocol
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: style,
            stateManager: stateManager,
            internalModel: internalModel,
            internalHeaderModel: nil,
            output: output
        )
    }
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetDataviewInternalViewModelProtocol,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        make(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: style,
            stateManager: stateManager,
            internalModel: internalModel,
            internalHeaderModel: internalModel,
            output: output
        )
    }
    
    // MARK: - Private
    
    @MainActor
    func make(
        widgetBlockId: String,
        widgetObject: BaseDocumentProtocol,
        style: ListWidgetStyle,
        stateManager: HomeWidgetsStateManagerProtocol,
        internalModel: WidgetInternalViewModelProtocol,
        internalHeaderModel: WidgetDataviewInternalViewModelProtocol?,
        output: CommonWidgetModuleOutput?
    ) -> AnyView {
        
        let contentModel = ListWidgetViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: style,
            internalModel: internalModel,
            internalHeaderModel: internalHeaderModel,
            output: output
        )
        let contentView = ListWidgetView(model: contentModel)
        
        let containerModel = WidgetContainerViewModel(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            stateManager: stateManager,
            contentModel: contentModel,
            output: output
        )
        let containterView = WidgetContainerView(
            model: containerModel,
            contentModel: contentModel,
            content: contentView
        )
        return containterView.eraseToAnyView()
    }
}
