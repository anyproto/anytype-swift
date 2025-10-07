import SwiftUI

public extension View {
    func snackbar(toastBarData: Binding<ToastBarData?>) -> some View {
        modifier(ToastModififer(toastBarData: toastBarData))
    }
}

public enum ToastMessageType {
    case neutral
    case success
    case failure
}

private struct ToastModififer: ViewModifier {
    
    @Binding var toastBarData: ToastBarData?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: toastBarData) { _, newValue in
                guard let newValue else { return }
                switch newValue.type {
                case .success:
                    ToastManager.showSuccessAlert(message: newValue.text)
                case .failure:
                    ToastManager.showFailureAlert(message: newValue.text)
                case .neutral:
                    ToastManager.show(message: newValue.text)
                }
                toastBarData = nil
            }
    }
}
