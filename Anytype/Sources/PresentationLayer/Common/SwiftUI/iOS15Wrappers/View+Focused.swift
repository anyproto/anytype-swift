import SwiftUI


struct FocusedModifier: ViewModifier {
    
    @FocusState var focusedField: Bool
    @Binding var focused: Bool
    
    init(focused: Binding<Bool>) {
        self._focused = focused
    }
    
    func body(content: Content) -> some View {
        content
            .focused($focusedField)
            .onChange(of: focused) { _, newValue in
                focusedField = newValue
            }
            .onAppear {
                // Sync state for first time
                focusedField = focused
            }
    }
}


extension View {
    func focused(_ focused: Binding<Bool>) -> some View {
        return self.modifier(FocusedModifier(focused: focused))
    }
}
