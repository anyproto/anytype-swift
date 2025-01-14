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
    
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        viewController.additionalSafeAreaInsets = pageEditorAdditionalSafeAreaInsets
    }
}
