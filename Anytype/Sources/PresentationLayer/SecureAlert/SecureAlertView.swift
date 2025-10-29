import SwiftUI
import DesignKit

struct SecureAlertView: View {
    
    @StateObject private var model: SecureAlertViewModel
    @Environment(\.dismiss) var dismiss
    
    init(data: SecureAlertData) {
        _model = StateObject(wrappedValue: SecureAlertViewModel(data: data))
    }
    
    var body: some View {
        GradientHeaderAlertView(
            title: Loc.SecureAlert.title,
            message: Loc.SecureAlert.message,
            style: .red,
            headerContentView: { headerContent },
            buttons: [
                GradientHeaderAlertButton(
                    title: Loc.openSettings,
                    style: .primaryLarge,
                    action: { model.openSettings() }
                ),
                GradientHeaderAlertButton(
                    title: Loc.SecureAlert.Proceed.button,
                    style: .secondaryLarge,
                    inProgress: model.inProgress,
                    action: { model.proceedTap() }
                )
            ]
        )
        .task(item: model.proceedTaskId) { _ in
            await model.proceed()
        }
        .onChange(of: model.dismiss) {
            dismiss()
        }
    }
    
    private var headerContent: some View {
        VStack(spacing: 0) {
            Spacer()
            
            Spacer.fixedHeight(16)
            
            Image(asset: .Secure.screenTop)
        }
    }
}

#Preview {
    SecureAlertView(data: SecureAlertData(completion: { _ in }))
}
