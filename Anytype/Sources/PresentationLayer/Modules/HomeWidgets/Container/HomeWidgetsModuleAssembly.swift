import Foundation
import SwiftUI

protocol HomeWidgetsModuleAssemblyProtocol {
    @MainActor
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView
}

final class HomeWidgetsModuleAssembly: HomeWidgetsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    private let widgetsDI: WidgetsDIProtocol
    
    init(serviceLocator: ServiceLocator, uiHelpersDI: UIHelpersDIProtocol, widgetsDI: WidgetsDIProtocol) {
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
        self.widgetsDI = widgetsDI
    }
    
    // MARK: - HomeWidgetsModuleAssemblyProtocol
    @MainActor
    func make(widgetObjectId: String, output: HomeWidgetsModuleOutput) -> AnyView {
        let model = HomeWidgetsViewModel(
            widgetObject: HomeWidgetsObject(
                objectId: widgetObjectId,
                objectDetailsStorage: serviceLocator.objectDetailsStorage()
            ),
            registry: widgetsDI.homeWidgetsRegistry(),
            blockWidgetService: serviceLocator.blockWidgetService(),
            toastPresenter: DI.makeForPreview().uihelpersDI.toastPresenter,
            output: output
        )
        let view = HomeWidgetsView(model: model)
        return view.eraseToAnyView()
    }
}
