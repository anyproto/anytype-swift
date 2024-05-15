import Foundation
import SwiftUI

protocol HomeCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class HomeCoordinatorAssembly: HomeCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
    }
    
    // MARK: - HomeCoordinatorAssemblyProtocol
    
    @MainActor
    func make() -> AnyView {
        return HomeCoordinatorView(model: self.makeModel()).eraseToAnyView()
    }
    
    // MARK: - Private func
    
    @MainActor
    private func makeModel() -> HomeCoordinatorViewModel {
        HomeCoordinatorViewModel(
            homeWidgetsModuleAssembly: modulesDI.homeWidgets(),
            editorCoordinatorAssembly: coordinatorsID.editor(),
            setObjectCreationCoordinatorAssembly: coordinatorsID.setObjectCreation(),
            sharingTipCoordinator: coordinatorsID.sharingTip()
        )
    }
}

