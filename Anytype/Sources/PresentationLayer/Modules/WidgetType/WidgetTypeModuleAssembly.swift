import Foundation
import SwiftUI
import BlocksModels

protocol WidgetTypeModuleAssemblyProtocol: AnyObject {
    
    // MARK: - Common
    
    func make(details: ObjectDetails, internalModel: WidgetTypeInternalViewModelProtocol) -> UIViewController
    
    // MARK: - Specific
    
    func makeCreateWidget(
        widgetObjectId: String,
        sourceObjectDetails: ObjectDetails,
        onFinish: @escaping () -> Void
    ) -> UIViewController
    
}

final class WidgetTypeModuleAssembly: WidgetTypeModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make(details: ObjectDetails, internalModel: WidgetTypeInternalViewModelProtocol) -> UIViewController {
        let model = WidgetTypeViewModel(details: details, internalModel: internalModel)
        let view = WidgetTypeView(model: model).eraseToAnyView()
        return AnytypePopup(contentView: view)
    }
    
    func makeCreateWidget(
        widgetObjectId: String,
        sourceObjectDetails: ObjectDetails,
        onFinish: @escaping () -> Void
    ) -> UIViewController {
        let internalModel = WidgetTypeCreateObjectViewModel(
            widgetObjectId: widgetObjectId,
            objectDetails: sourceObjectDetails,
            blockWidgetService: serviceLocator.blockWidgetService(),
            onFinish: onFinish
        )
        
        return make(details: sourceObjectDetails, internalModel: internalModel)
    }
}
