import SwiftUI


@MainActor
extension View {
    func alertView(isShowing: Binding<Bool>, errorText: String, onButtonTap: @escaping () -> () = {}) -> some View {
        AlertView(isShowing: isShowing, errorText: errorText, presenting: self, onButtonTap: onButtonTap)
    }
    
    func embedInNavigation() -> some View {
        NavigationView { self }
    }
}

extension View {
    
    func transparencyEffect(edge: TransparencyEffect.Edge, length: CGFloat) -> some View {
        modifier(TransparencyEffectModifier(edge: edge, length: length))
    }
    
}
