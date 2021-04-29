import SwiftUI


extension View {
    func errorToast(isShowing: Binding<Bool>, errorText: String) -> some View {
        ErrorAlertView(isShowing: isShowing, errorText: errorText, presenting: self)
    }

    func eraseToAnyView() -> AnyView {
        .init(self)
    }
}
