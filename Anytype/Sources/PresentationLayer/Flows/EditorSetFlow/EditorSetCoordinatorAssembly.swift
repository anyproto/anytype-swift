import Foundation
import SwiftUI

protocol EditorSetCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorSetObject) -> AnyView
}

final class EditorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.serviceLocator = serviceLocator
        self.uiHelpersDI = uiHelpersDI
    }
    
    // MARK: - EditorSetCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: EditorSetObject) -> AnyView {
        EditorSetCoordinatorView(
            model: EditorSetCoordinatorViewModel(
                data: data,
                setObjectCreationCoordinator: self.coordinatorsID.setObjectCreation().make(),
                setObjectCreationSettingsCoordinator: self.coordinatorsID.setObjectCreationSettings().make(with: nil), 
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                navigationContext: self.uiHelpersDI.commonNavigationContext()
            )
        ).eraseToAnyView()
    }
}

