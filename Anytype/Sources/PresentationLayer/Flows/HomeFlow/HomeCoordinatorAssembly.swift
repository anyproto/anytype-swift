import Foundation
import SwiftUI

protocol HomeCoordinatorAssemblyProtocol {
    @MainActor
    func make() -> AnyView
}

final class HomeCoordinatorAssembly: HomeCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    
    init(
        coordinatorsID: CoordinatorsDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
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
            editorCoordinatorAssembly: coordinatorsID.editor()
        )
    }
}

