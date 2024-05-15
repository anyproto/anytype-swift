import Foundation
import SwiftUI

@MainActor
final class EditorCoordinatorViewModel: ObservableObject, WidgetObjectListCommonModuleOutput {
    
    var pageNavigation: PageNavigation?
    
    let data: EditorScreenData
    private let editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    private let editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    
    init(
        data: EditorScreenData,
        editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol,
        editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    ) {
        self.data = data
        self.editorPageCoordinatorAssembly = editorPageCoordinatorAssembly
        self.editorSetCoordinatorAssembly = editorSetCoordinatorAssembly
    }
    
    func makePage(data: EditorPageObject) -> AnyView {
        editorPageCoordinatorAssembly.make(data: data, showHeader: true, setupEditorInput: { _, _ in })
    }
    
    func makeSet(data: EditorSetObject) -> AnyView {
        editorSetCoordinatorAssembly.make(data: data)
    }
    
    // MARK: - WidgetObjectListCommonModuleOutput
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
}
