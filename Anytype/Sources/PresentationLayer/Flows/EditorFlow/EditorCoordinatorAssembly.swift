import Foundation
import SwiftUI

@MainActor
protocol EditorCoordinatorAssemblyProtocol {
    func make(data: EditorScreenData) -> AnyView
}

@MainActor
final class EditorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    
    nonisolated init(coordinatorsID: CoordinatorsDIProtocol) {
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - EditorCoordinatorAssemblyProtocol
    
    func make(data: EditorScreenData) -> AnyView {
        return EditorCoordinatorView(
            model: EditorCoordinatorViewModel(
                data: data
            )
        ).eraseToAnyView()
    }
}
