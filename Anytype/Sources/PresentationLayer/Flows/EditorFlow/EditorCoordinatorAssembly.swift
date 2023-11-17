import Foundation
import SwiftUI

@MainActor
protocol EditorCoordinatorAssemblyProtocol {
    func make(data: EditorScreenData) -> AnyView
}

@MainActor
final class EditorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(coordinatorsID: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
    }
    
    // MARK: - EditorCoordinatorAssemblyProtocol
    
    func make(data: EditorScreenData) -> AnyView {
        return EditorCoordinatorView(
            model: EditorCoordinatorViewModel(
                data: data,
                widgetObjectListModuleAssembly: self.modulesDI.widgetObjectList(),
                editorPageCoordinatorAssembly: self.coordinatorsID.editorPage(),
                editorSetCoordinatorAssembly: self.coordinatorsID.editorSet()
            )
        ).eraseToAnyView()
    }
}
