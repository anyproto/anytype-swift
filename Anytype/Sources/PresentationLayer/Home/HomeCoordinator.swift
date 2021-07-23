import SwiftUI

final class HomeCoordinator {
    
    // MARK: - Private variables
    
    private let settingsAssembly: SettingsAssembly
    private let editorAssembly: EditorAssembly
    
    // MARK: - Initializers
    
    init(
        settingsAssembly: SettingsAssembly,
        editorAssembly: EditorAssembly
    ) {
        self.settingsAssembly = settingsAssembly
        self.editorAssembly = editorAssembly
    }
    
    // MARK: - Internal functions
    
    func settingsView() -> some View {
        settingsAssembly.settingsView()
    }
    
    func documentView(selectedDocumentId: String) -> some View {
        editorAssembly.documentView(
            blockId: selectedDocumentId
        )
        .eraseToAnyView()
        .edgesIgnoringSafeArea(.all)
    }
    
}
