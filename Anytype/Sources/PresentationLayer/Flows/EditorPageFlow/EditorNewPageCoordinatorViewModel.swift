import Foundation
import SwiftUI

@MainActor
final class EditorNewPageCoordinatorViewModel: ObservableObject, EditorPageModuleOutput {
    
    private let data: EditorPageObject
    private let editorPageAssembly: EditorPageModuleAssemblyProtocol
    
    var pageNavigation: PageNavigation?
    
    init(data: EditorPageObject,editorPageAssembly: EditorPageModuleAssemblyProtocol) {
        self.data = data
        self.editorPageAssembly = editorPageAssembly
    }
    
    func pageModule() -> AnyView {
        return editorPageAssembly.make(data: data, output: self)
    }
    
    // MARK: - EditorPageModuleOutput
    
    func showEditorScreen(data: EditorScreenData) {
        pageNavigation?.push(data)
    }
    
    func replaceEditorScreen(data: EditorScreenData) {
        pageNavigation?.replace(data)
    }
}
