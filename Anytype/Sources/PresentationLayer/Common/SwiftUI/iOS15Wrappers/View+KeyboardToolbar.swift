import SwiftUI

struct KeyboardToolbar: ViewModifier {
    
    @ViewBuilder
    func body(content: Content) -> some View {
        NavigationView {
            content
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        KeyboardToolbarView()
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}

extension View {
    func keyboardToolbar() -> some View {
        modifier(KeyboardToolbar())
    }
}
