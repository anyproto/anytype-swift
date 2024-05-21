import Foundation
import SwiftUI

@MainActor
protocol EditorPageCoordinatorAssemblyProtocol {
    func make(
        data: EditorPageObject,
        showHeader: Bool,
        // TODO: Refactoring templates. Delete it
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void
    ) -> AnyView
}

@MainActor
final class EditorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    
    nonisolated init(
        coordinatorsID: CoordinatorsDIProtocol
    ) {
        self.coordinatorsID = coordinatorsID
    }
    
    // MARK: - EditorNewPageCoordinatorAssemblyProtocol
    
    @MainActor
    func make(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void
    ) -> AnyView {
        return EditorPageCoordinatorView(
            model: EditorPageCoordinatorViewModel(
                data: data,
                showHeader: showHeader,
                setupEditorInput: setupEditorInput,
                editorPageAssembly: self.coordinatorsID.editorPageModule()
            )
        ).eraseToAnyView()
    }
}

