import Foundation
import SwiftUI

final class EditorNewPageCoordinatorViewModel: ObservableObject {
    
    private let data: EditorPageObject
    private let editorAssembly: EditorAssembly
    
    init(data: EditorPageObject, editorAssembly: EditorAssembly) {
        self.data = data
        self.editorAssembly = editorAssembly
    }
    
    func pageModule() -> AnyView {
        return editorAssembly.buildPageModule(browser: nil, data: data).0.eraseToAnyView()
    }
}
