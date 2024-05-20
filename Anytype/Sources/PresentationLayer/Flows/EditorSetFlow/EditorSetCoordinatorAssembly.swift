import Foundation
import SwiftUI

protocol EditorSetCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorSetObject) -> AnyView
}

final class EditorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        serviceLocator: ServiceLocator
    ) {
        self.coordinatorsID = coordinatorsID
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - EditorSetCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: EditorSetObject) -> AnyView {
        EditorSetCoordinatorView(
            model: EditorSetCoordinatorViewModel(
                data: data,
                setObjectCreationSettingsCoordinator: self.coordinatorsID.setObjectCreationSettings().make()
            )
        ).eraseToAnyView()
    }
}

