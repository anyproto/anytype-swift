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
        
        return ListWidgetView(
            widgetBlockId: widgetBlockId,
            widgetObject: widgetObject,
            style: style,
            stateManager: stateManager,
            internalModel: internalModel,
            internalHeaderModel: internalHeaderModel,
            output: output
        ).eraseToAnyView()
    }
}
