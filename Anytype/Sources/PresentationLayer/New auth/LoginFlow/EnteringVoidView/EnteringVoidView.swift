import SwiftUI

struct EnteringVoidView: View {
    
    @StateObject var model: EnteringVoidViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            AnytypeText(Loc.Auth.LoginFlow.Entering.Void.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            Spacer()
        }
        .navigationBarHidden(true)
        .onAppear {
            model.onAppear()
        }
        .ifLet(model.errorText) { view, errorText in
            view.alertView(isShowing: $model.showError, errorText: errorText) {
                presentationMode.dismiss()
            }
        }
        .onChange(of: model.dismiss) { newValue in
            guard newValue else { return }
            presentationMode.dismiss()
        }
    }
}


struct EnteringVoidView_Previews : PreviewProvider {
    static var previews: some View {
        EnteringVoidView(
            model: EnteringVoidViewModel(
                output: nil,
                applicationStateService: DI.preview.serviceLocator.applicationStateService(),
                authService: DI.preview.serviceLocator.authService(),
                metricsService: DI.preview.serviceLocator.metricsService(),
                accountEventHandler: DI.preview.serviceLocator.accountEventHandler()
            )
        )
    }
}
