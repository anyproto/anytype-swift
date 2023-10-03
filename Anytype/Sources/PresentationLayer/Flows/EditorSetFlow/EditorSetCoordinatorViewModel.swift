import Foundation
import SwiftUI

@MainActor
final class EditorSetCoordinatorViewModel: ObservableObject, EditorSetModuleOutput {
    
    private let data: EditorSetObject
    private let editorSetAssembly: EditorSetModuleAssemblyProtocol
    
    init(data: EditorSetObject, editorSetAssembly: EditorSetModuleAssemblyProtocol) {
        self.data = data
        self.editorSetAssembly = editorSetAssembly
    }
    
    func setModule() -> AnyView {
        return editorSetAssembly.make(data: data, output: self)
    }
    
    // MARK: - EditorSetModuleOutput
}
