import Foundation
import SwiftUI

@MainActor
final class EditorPageCoordinatorViewModel: ObservableObject, EditorPageModuleOutput {
    
    private let data: EditorPageObject
    private let showHeader: Bool
    private let setupEditorInput: (EditorPageModuleInput, String) -> Void
    private let editorPageAssembly: EditorPageModuleAssemblyProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    
    init(
        data: EditorPageObject,
        showHeader: Bool,
        setupEditorInput: @escaping (EditorPageModuleInput, String) -> Void,
        editorPageAssembly: EditorPageModuleAssemblyProtocol
    ) {
        self.data = data
        self.showHeader = showHeader
        self.setupEditorInput = setupEditorInput
        self.editorPageAssembly = editorPageAssembly
    }
    
    func pageModule() -> AnyView {
        return editorPageAssembly.make(data: data, output: self, showHeader: showHeader)
    }
    
    // MARK: - EditorPageModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
    
    func setModuleInput(input: EditorPageModuleInput, objectId: String) {
        setupEditorInput(input, objectId)
    }
}
