import SwiftUI

struct KeyboardToolbar: ViewModifier {
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            NavigationView {
                content
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            KeyboardToolbarView()
                        }
                    }
            }
            .navigationViewStyle(.stack)
        } else {
            content
        }
    }
}

extension View {
    func keyboardToolbar() -> some View {
        modifier(KeyboardToolbar())
    }
}
