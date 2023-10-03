import Foundation
import SwiftUI

protocol EditorPageCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorPageObject) -> AnyView
}

final class EditorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol {
    
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
        return EditorPageCoordinatorView(
            model: EditorPageCoordinatorViewModel(data: data, editorPageAssembly: self.coordinatorsID.editorPageModule())
        ).eraseToAnyView()
    }
}

