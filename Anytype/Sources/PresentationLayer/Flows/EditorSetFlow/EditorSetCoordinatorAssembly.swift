import Foundation
import SwiftUI

protocol EditorSetCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorSetObject) -> AnyView
}

final class EditorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol
   ) {
        self.coordinatorsID = coordinatorsID
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

