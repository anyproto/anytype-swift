import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            Gradients.mainBackground()
            loginNavigation
            bottomSheet
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        
        .ifLet(viewModel.error) { view, error in
            view.errorToast(isShowing: $viewModel.showError, errorText: error)
        }
        .alert(isPresented: $viewModel.openSettingsURL) {
            AlertsFactory.goToSettingsAlert(title: "Auth.CameraPermissionTitle".localized)
        }
        .sheet(isPresented: $viewModel.showQrCodeView) {
            QRCodeScannerView(qrCode: self.$viewModel.entropy, error: self.$viewModel.error)
        }
    }
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            keychainPhraseView
                .padding(20)
        }
    }

    private var keychainPhraseView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText("Login with keychain".localized, style: .heading, color: .textPrimary)
                Spacer.fixedHeight(32)
                scanQR
                enterMnemonic
                buttons
            }
            .padding(EdgeInsets(top: 23, leading: 20, bottom: 10, trailing: 20))
        }
        .background(Color.background)
        .cornerRadius(16.0)
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            StandardButton(text: "Back".localized, style: .secondary) {
                self.presentationMode.wrappedValue.dismiss()
            }

            StandardButton(disabled: viewModel.seed.isEmpty, text: "Login".localized, style: .primary) {
                self.viewModel.recoverWallet()
            }
        }
    }
    
    // Workaround for text editor placeholder
    // https://stackoverflow.com/a/62742668/6252099
    private var enterMnemonic: some View {
        ZStack(alignment: .topLeading) {
            if(viewModel.seed.isEmpty) {
                AnytypeText("or Type your keychain phrase".localized, style: .codeBlock, color: .textSecondary)
                    .padding(.top, 17)
            }
            
            AutofocusedTextEditor(text: $viewModel.seed).lineLimit(3)
                .font(AnytypeFontBuilder.font(anytypeFont: .codeBlock))
                .lineSpacing(AnytypeFont.codeBlock.lineSpacing)
                .foregroundColor(.textPrimary)
                .padding(.top, 9)
                .padding(.leading, -5)
                .opacity(viewModel.seed.isEmpty ? 0.25 : 1)
                .autocapitalization(.none)
                .frame(height: 124)
                .textContentType(.password)
        }
    }
    
    private var scanQR: some View {
        Button(
            action: {
                UIApplication.shared.hideKeyboard()
                viewModel.onShowQRCodeTap()
            }
        ) {
            HStack {
                AnytypeText("Scan QR code".localized, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                Image.arrow
            }
            .modifier(DividerModifier(spacing: 10))
        }
    }
    
    private var loginNavigation: some View {
        NavigationLink(
            destination: SelectProfileView(viewModel: SelectProfileViewModel()),
            isActive: $viewModel.showSelectProfile
        ) {
            EmptyView()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
