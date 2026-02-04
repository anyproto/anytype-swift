import SwiftUI

struct KeyboardToolbar: ViewModifier {
    
    @ViewBuilder
    func body(content: Content) -> some View {
        NavigationStack {
            content
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        KeyboardToolbarView()
                    }
                }
        }
    }
}

extension View {
    func keyboardToolbar() -> some View {
        modifier(KeyboardToolbar())
    }
}
