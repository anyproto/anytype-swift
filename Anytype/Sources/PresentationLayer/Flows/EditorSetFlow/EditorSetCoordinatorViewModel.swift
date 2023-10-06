import Foundation
import SwiftUI

@MainActor
final class EditorSetCoordinatorViewModel: ObservableObject, EditorSetModuleOutput {
    
    private let data: EditorSetObject
    private let editorSetAssembly: EditorSetModuleAssemblyProtocol
    
    var pageNavigation: PageNavigation?
    @Published var dismiss = false
    
    init(data: EditorSetObject, editorSetAssembly: EditorSetModuleAssemblyProtocol) {
        self.data = data
        self.editorSetAssembly = editorSetAssembly
    }
    
    func setModule() -> AnyView {
        return editorSetAssembly.make(data: data, output: self)
    }
    
    // MARK: - EditorSetModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
    
    func closeEditor() {
        dismiss.toggle()
    }
}
