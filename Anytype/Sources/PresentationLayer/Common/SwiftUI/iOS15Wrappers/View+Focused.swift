import SwiftUI

@available(iOS 15.0, *)
struct FocusedModifier: ViewModifier {
    
    @FocusState var focusedField: Bool
    @Binding var focused: Bool
    
    init(focused: Binding<Bool>) {
        self._focused = focused
    }
    
    func body(content: Content) -> some View {
        content
            .focused($focusedField)
            .onChange(of: focused) { newValue in
                focusedField = newValue
            }
            .onAppear {
                // Sync state for first time
                focusedField = focused
            }
    }
}


@available(iOS, deprecated: 15)
extension View {
    func focusedLefacy(_ focused: Binding<Bool>) -> some View {
        if #available(iOS 15.0, *) {
            return self.modifier(FocusedModifier(focused: focused))
        } else {
            return self
        }
    }
}
