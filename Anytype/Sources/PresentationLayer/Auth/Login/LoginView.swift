import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            loginNavigation
            keychainPhraseView.padding()
        }
        .navigationBarHidden(true)
        .modifier(LogoOverlay())
    }

    private var keychainPhraseView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText("Login with keychain", style: .title)
                    .padding(.bottom, 32)
                    .padding(.top, 23)
                
                scanQR
                enterMnemonic
 
                HStack(spacing: 12) {
                    StandardButton(text: "Back", style: .secondary) {
                        self.presentationMode.wrappedValue.dismiss()
                    }

                    StandardButton(disabled: viewModel.seed.isEmpty, text: "Login", style: .primary) {
                        self.viewModel.recoverWallet()
                    }
                }
                .padding(.bottom, 16)
            }
            .padding()
            .background(Color.background)
            .cornerRadius(16.0)
            .sheet(isPresented: $viewModel.showQrCodeView) {
                QRCodeScannerView(qrCode: self.$viewModel.entropy, error: self.$viewModel.error)
            }
        }
        .ifLet(viewModel.error) { view, error in
            view.errorToast(isShowing: $viewModel.showError, errorText: error)
        }
    }
    
    // Workaround for text editor placeholder
    // https://stackoverflow.com/a/62742668/6252099
    private var enterMnemonic: some View {
        ZStack(alignment: .topLeading) {
            if(viewModel.seed.isEmpty) {
                AnytypeText("or Type your keychain phrase", style: .codeBlock)
                    .foregroundColor(.textSecondary)
                    .padding(.top, 20)
                    .padding(.leading, 6)
            }
            
            TextEditor(text: $viewModel.seed).lineLimit(3)
                .font(AnytypeFontBuilder.font(textStyle: .codeBlock))
                .lineSpacing(AnytypeFontBuilder.lineSpacing(.codeBlock))
                .frame(height: 80)
                .foregroundColor(.textSecondary)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .opacity(viewModel.seed.isEmpty ? 0.25 : 1)
                .autocapitalization(.none)
        }
    }
    
    private var scanQR: some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            viewModel.showQrCodeView = true
        }) {
            VStack(spacing: 10) {
                HStack {
                    AnytypeText("Scan QR code", style: .uxBodyRegular)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Image.arrow
                }
                Divider()
            }
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
