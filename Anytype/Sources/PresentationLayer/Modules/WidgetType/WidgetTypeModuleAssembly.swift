import Foundation
import SwiftUI
import Services

protocol WidgetTypeModuleAssemblyProtocol: AnyObject {
    
    // MARK: - Common
    
    @MainActor
    func make(internalModel: @autoclosure @escaping () -> WidgetTypeInternalViewModelProtocol) -> AnyView
    
    // MARK: - Specific
    
    @MainActor
    func makeCreateWidget(data: WidgetTypeModuleCreateModel) -> AnyView
 
    @MainActor
    func makeChangeType(data: WidgetTypeModuleChangeModel) -> AnyView
}

final class WidgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - WidgetTypeModuleAssemblyProtocol
    
    @MainActor
    func make(internalModel: @autoclosure @escaping () -> WidgetTypeInternalViewModelProtocol) -> AnyView {
        return WidgetTypeView(model: WidgetTypeViewModel(internalModel: internalModel())).eraseToAnyView()
    }
    
    @MainActor
    func makeCreateWidget(data: WidgetTypeModuleCreateModel) -> AnyView {
        return make(internalModel: WidgetTypeCreateObjectViewModel(
            widgetObjectId: data.widgetObjectId,
            source: data.source,
            position: data.position,
            blockWidgetService: self.serviceLocator.blockWidgetService(),
            context: data.context,
            onFinish: data.onFinish
        ))
    }
    
    @MainActor
    func makeChangeType(data: WidgetTypeModuleChangeModel) -> AnyView {
        return make(internalModel: WidgetTypeChangeViewModel(
            widgetObjectId: data.widgetObjectId,
            widgetId: data.widgetId,
            blockWidgetService: self.serviceLocator.blockWidgetService(),
            documentService: self.serviceLocator.documentService(),
            context: data.context,
            onFinish: data.onFinish
        ))
    }
}
