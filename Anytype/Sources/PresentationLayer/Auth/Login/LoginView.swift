import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            loginNavigation
            bottomSheet
        }
        .navigationBarHidden(true)
        
        .ifLet(viewModel.error) { view, error in
            view.errorToast(isShowing: $viewModel.showError, errorText: error)
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
                AnytypeText("Login with keychain", style: .heading)
                    .padding(.bottom, 32)
                scanQR
                enterMnemonic
                buttons
            }
            .padding(.top, 23)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        }
        .background(Color.background)
        .cornerRadius(16.0)
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            StandardButton(text: "Back", style: .secondary) {
                self.presentationMode.wrappedValue.dismiss()
            }

            StandardButton(disabled: viewModel.seed.isEmpty, text: "Login", style: .primary) {
                self.viewModel.recoverWallet()
            }
        }
    }
    
    // Workaround for text editor placeholder
    // https://stackoverflow.com/a/62742668/6252099
    private var enterMnemonic: some View {
        ZStack(alignment: .topLeading) {
            if(viewModel.seed.isEmpty) {
                AnytypeText("or Type your keychain phrase", style: .codeBlock)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 17)
                    .padding(.leading, 6)
            }
            
            TextEditor(text: $viewModel.seed).lineLimit(3)
                .font(AnytypeFontBuilder.font(textStyle: .codeBlock))
                .lineSpacing(AnytypeFontBuilder.lineSpacing(.codeBlock))
                .foregroundColor(.textSecondary)
                .padding(.top, 9)
                .opacity(viewModel.seed.isEmpty ? 0.25 : 1)
                .autocapitalization(.none)
                .frame(height: 124)
        }
    }
    
    private var scanQR: some View {
        Button(
            action: {
                UIApplication.shared.hideKeyboard()
                viewModel.showQrCodeView = true
            }
        ) {
            HStack {
                AnytypeText("Scan QR code", style: .uxBodyRegular)
                    .foregroundColor(.textPrimary)
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
