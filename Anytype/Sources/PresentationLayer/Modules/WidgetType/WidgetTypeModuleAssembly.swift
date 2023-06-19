import Foundation
import SwiftUI
import Services

protocol WidgetTypeModuleAssemblyProtocol: AnyObject {
    
    // MARK: - Common
    
    @MainActor
    func make(internalModel: WidgetTypeInternalViewModelProtocol) -> UIViewController
    
    // MARK: - Specific
    
    @MainActor
    func makeCreateWidget(
        widgetObjectId: String,
        source: WidgetSource,
        position: WidgetPosition,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) -> UIViewController
 
    @MainActor
    func makeChangeType(
        widgetObjectId: String,
        widgetId: String,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) -> UIViewController
}

final class WidgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - WidgetTypeModuleAssemblyProtocol
    
    @MainActor
    func make(internalModel: WidgetTypeInternalViewModelProtocol) -> UIViewController {
        let model = WidgetTypeViewModel(internalModel: internalModel)
        let view = WidgetTypeView(model: model).eraseToAnyView()
        return AnytypePopup(contentView: view)
    }
    
    @MainActor
    func makeCreateWidget(
        widgetObjectId: String,
        source: WidgetSource,
        position: WidgetPosition,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let internalModel = WidgetTypeCreateObjectViewModel(
            widgetObjectId: widgetObjectId,
            source: source,
            position: position,
            blockWidgetService: serviceLocator.blockWidgetService(),
            context: context,
            onFinish: onFinish
        )
        
        return make(internalModel: internalModel)
    }
    
    @MainActor
    func makeChangeType(
        widgetObjectId: String,
        widgetId: String,
        context: AnalyticsWidgetContext,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let internalModel = WidgetTypeChangeViewModel(
            widgetObjectId: widgetObjectId,
            widgetId: widgetId,
            blockWidgetService: serviceLocator.blockWidgetService(),
            documentService: serviceLocator.documentService(),
            context: context,
            onFinish: onFinish
        )
        return make(internalModel: internalModel)
    }
}
