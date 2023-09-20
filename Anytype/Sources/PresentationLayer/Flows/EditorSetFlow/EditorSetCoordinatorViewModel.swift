import Foundation
import SwiftUI

final class EditorSetCoordinatorViewModel: ObservableObject {
    
    private let data: EditorSetObject
    private let editorAssembly: EditorAssembly
    
    init(data: EditorSetObject, editorAssembly: EditorAssembly) {
        self.data = data
        self.editorAssembly = editorAssembly
    }
    
    func setModule() -> AnyView {
        return editorAssembly.buildSetModule(browser: nil, data: data).0.eraseToAnyView()
    }
}
