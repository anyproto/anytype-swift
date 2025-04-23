import SwiftUI

public extension View {
    func snackbar(toastBarData: Binding<ToastBarData>) -> some View {
        modifier(ToastModififer(toastBarData: toastBarData))
    }
}

public enum ToastMessageType {
    case none
    case success
    case failure
}

private struct ToastModififer: ViewModifier {
    
    @Binding var toastBarData: ToastBarData
    
    func body(content: Content) -> some View {
        content
            .onChange(of: toastBarData) { newValue in
                if newValue.showSnackBar {
                    switch newValue.messageType {
                        case .success:
                            ToastPresenter.showSuccessAlert(message: newValue.text)
                        case .failure:
                            ToastPresenter.showFailureAlert(message: newValue.text)
                        case .none:
                            ToastPresenter.show(message: newValue.text)
                    }
                }
                toastBarData = .empty
            }
    }
}
