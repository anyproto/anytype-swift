import SwiftUI

struct LoginView: View {
    
    @ObservedObject var model: LoginViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Loc.login)
            .navigationBarTitleDisplayMode(.inline)
            .background(TransparentBackground())
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    backButton
                }
            }
            .sheet(isPresented: $model.showQrCodeView) {
                QRCodeScannerView(qrCode: self.$model.entropy, error: self.$model.errorText)
            }
            .alert(isPresented: $model.openSettingsURL) {
                AlertsFactory.goToSettingsAlert(title: Loc.Auth.cameraPermissionTitle)
            }
            .ifLet(model.errorText) { view, errorText in
                view.alertView(isShowing: $model.showError, errorText: errorText)
            }
            .onAppear {
                model.onAppear()
            }
            .fitIPadToReadableContentGuide()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            PhraseTextView(text: $model.phrase, expandable: false)
                .focused($model.autofocus)
            
            Spacer.fixedHeight(16)

            buttonsBlock
            
            Spacer()
        }
    }
    
    private var buttonsBlock : some View {
        VStack(spacing: 12) {
            StandardButton(
                Loc.Auth.LoginFlow.Enter.Button.title,
                inProgress: model.walletRecoveryInProgress,
                style: .primaryLarge,
                action: {
                    model.onEnterButtonAction()
                }
            )
            .colorScheme(model.phrase.isEmpty ? .dark : .light)
            .disabled(model.phrase.isEmpty)
            .addEmptyNavigationLink(destination: model.onNextAction(), isActive: $model.showEnteringVoidView)
            
            AnytypeText(
                Loc.Auth.LoginFlow.or,
                style: .caption2Medium,
                color: .Auth.inputText
            )
            
            HStack(spacing: 8) {
                StandardButton(
                    Loc.scanQRCode,
                    style: .secondaryLarge,
                    action: {
                        model.onScanQRButtonAction()
                    }
                )
                
                if model.canRestoreFromKeychain {
                    StandardButton(
                        Loc.Auth.LoginFlow.Use.Keychain.title,
                        style: .secondaryLarge,
                        action: {
                            model.onKeychainButtonAction()
                        }
                    )
                }
            }
        }
    }
    
    private var backButton : some View {
        Button(action: {
            presentationMode.dismiss()
        }) {
            Image(asset: .backArrow)
                .foregroundColor(.Text.tertiary)
        }
    }
}


struct LoginView_Previews : PreviewProvider {
    static var previews: some View {
        LoginView(
            model: LoginViewModel(
                authService: DI.preview.serviceLocator.authService(),
                seedService: DI.preview.serviceLocator.seedService(),
                localAuthService: DI.preview.serviceLocator.localAuthService(),
                cameraPermissionVerifier: DI.preview.serviceLocator.cameraPermissionVerifier(),
                output: nil
            )
        )
    }
}
