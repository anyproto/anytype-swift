import Foundation
import SwiftUI

protocol EditorNewPageCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorPageObject) -> AnyView
}

final class EditorNewPageCoordinatorAssembly: EditorNewPageCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorNewPageCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: EditorPageObject) -> AnyView {
        return EditorNewPageCoordinatorView(
            model: EditorNewPageCoordinatorViewModel(data: data, editorAssembly: self.coordinatorsID.editorLegacy())
        ).eraseToAnyView()
    }
}

