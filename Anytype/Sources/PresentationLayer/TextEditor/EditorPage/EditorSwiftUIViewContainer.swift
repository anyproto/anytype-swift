import SwiftUI

extension EnvironmentValues {
    @Entry var pageEditorAdditionalSafeAreaInsets: UIEdgeInsets = .zero
}

extension View {
    func pageEditorAdditionalSafeAreaInsets(_ insets: UIEdgeInsets) -> some View {
        environment(\.pageEditorAdditionalSafeAreaInsets, insets)
    }
}

struct EditorSwiftUIViewContainer: UIViewControllerRepresentable {
    
    @Environment(\.pageEditorAdditionalSafeAreaInsets) private var pageEditorAdditionalSafeAreaInsets
    @Environment(\.pageNavigationHiddenBackButton) private var pageNavigationHiddenBackButton
    
    let viewController: EditorPageController

    func makeUIViewController(context: Context) -> EditorPageController {
        viewController
    }
    
    func updateUIViewController(_ uiViewController: EditorPageController, context: Context) {
        viewController.additionalSafeAreaInsets = pageEditorAdditionalSafeAreaInsets
        viewController.setPageNavigationHiddenBackButton(pageNavigationHiddenBackButton)
    }
}
