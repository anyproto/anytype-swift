import SwiftUI

@available(iOS 15.0, *)
struct AutofocusedModifier: ViewModifier {
    
    @Binding var focused: Bool
    var delay: CGFloat
    
    func body(content: Content) -> some View {
        content
            .task {
                try? await Task.sleep(seconds: delay)
                focused = true
            }
    }
}

extension View {
    func autofocus(_ focused: Binding<Bool>, delay: CGFloat = 0.5) -> some View {
        if #available(iOS 15.0, *) {
            return self.modifier(AutofocusedModifier(focused: focused, delay: delay))
        } else {
            return self
        }
    }
}
