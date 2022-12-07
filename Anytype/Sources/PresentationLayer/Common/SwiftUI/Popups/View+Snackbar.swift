import SwiftUI

extension View {
    func snackbar(toastBarData: Binding<ToastBarData>) -> some View {
        ToastAlert(toastBarData: toastBarData, presenting: self)
    }
}

struct ToastAlert: View {
    enum MessageType {
        case none
        case success
        case failure
    }
    
    @Binding var toastBarData: ToastBarData
    private let presenting: AnyView
    
    init<Presenting>(
        toastBarData: Binding<ToastBarData>,
        presenting: Presenting
    ) where Presenting: View {
        _toastBarData = toastBarData
        self.presenting = presenting.eraseToAnyView()
    }
    
    var body: some View {
        presenting
            .onChange(of: toastBarData) { newValue in
                if newValue.showSnackBar {
                    switch newValue.messageType {
                        case .success:
                            ToastPresenter.shared?.showSuccessAlert(message: newValue.text)
                        case .failure:
                            ToastPresenter.shared?.showFailureAlert(message: newValue.text)
                        case .none:
                            ToastPresenter.shared?.show(message: newValue.text)
                    }
                }
                toastBarData = .empty
            }
    }
}


