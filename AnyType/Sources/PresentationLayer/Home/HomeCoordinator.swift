import SwiftUI

final class HomeCoordinator {
    private let settingsAssembly: SettingsAssembly
    private let editorAssembly: EditorAssembly
    init(
        settingsAssembly: SettingsAssembly,
        editorAssembly: EditorAssembly
    ) {
        self.settingsAssembly = settingsAssembly
        self.editorAssembly = editorAssembly
    }
    
    func settingsView() -> some View {
        settingsAssembly.settingsView()
    }
    
    func documentView(selectedDocumentId: String) -> some View {
        return editorAssembly.documentView(id: selectedDocumentId).eraseToAnyView().edgesIgnoringSafeArea(.all)
    }
}
