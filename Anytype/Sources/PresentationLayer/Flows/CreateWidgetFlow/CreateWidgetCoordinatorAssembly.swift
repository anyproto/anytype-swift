import Foundation
import SwiftUI

protocol CreateWidgetCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: CreateWidgetCoordinatorModel) -> AnyView
}

final class CreateWidgetCoordinatorAssembly: CreateWidgetCoordinatorAssemblyProtocol {
    
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - CreateWidgetCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: CreateWidgetCoordinatorModel) -> AnyView {
        return CreateWidgetCoordinatorView(
            model: CreateWidgetCoordinatorViewModel(
                data: data,
                newSearchModuleAssembly: self.modulesDI.newSearch(),
                widgetTypeModuleAssembly: self.modulesDI.widgetType(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage()
            )
        ).eraseToAnyView()
    }
}
