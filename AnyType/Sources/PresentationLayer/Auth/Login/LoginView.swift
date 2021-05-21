import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradients.authBackground, startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            keychainPhraseView.padding()
        }
    }

    private var keychainPhraseView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText("Login with keychain", style: .title)
                    .padding(.bottom, 27)
                
                scanQR
                enterMnemonic

                HStack(spacing: 12) {
                    StandardButton(disabled: false, text: "Back", style: .secondary) {
                        self.presentationMode.wrappedValue.dismiss()
                    }

                    StandardButton(disabled: false, text: "Login", style: .primary) {
                        self.viewModel.recoverWallet()
                    }
                }
                .padding(.bottom, 16)
            }
            .padding()
            .background(Color.background)
            .cornerRadius(12.0)
            .navigationBarBackButtonHidden(true)
            .sheet(isPresented: $viewModel.showQrCodeView) {
                QRCodeScannerView(qrCode: self.$viewModel.entropy, error: self.$viewModel.error)
            }
        }
        .errorToast(isShowing: $viewModel.showError, errorText: viewModel.error ?? "")
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
                .lineSpacing(AnytypeFontBuilder.customLineSpacing(textStyle: .codeBlock) ?? 7)
                .frame(height: 80)
                .foregroundColor(.textSecondary)
                .padding(.top, 12)
                .padding(.bottom, 24)
                .opacity(viewModel.seed.isEmpty ? 0.25 : 1)
        }

    }
    
    private var scanQR: some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            viewModel.showQrCodeView = true
        }) {
            VStack(spacing: 13) {
                HStack {
                    Image.auth.qr
                        .padding(.trailing, 15)
                    AnytypeText("Scan QR code", style: .headline).foregroundColor(.textPrimary)
                    Spacer()
                    Image.arrow
                }
                Divider()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
