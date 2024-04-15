import SwiftUI

struct LoginView: View {
    
    @StateObject private var model: LoginViewModel
    @Environment(\.presentationMode) @Binding private var presentationMode
    
    init(output: LoginFlowOutput?) {
        _model = StateObject(wrappedValue: LoginViewModel(output: output))
    }
    
    var body: some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationTitle(Loc.Auth.LoginFlow.Enter.title)
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
            .alert(Loc.Auth.cameraPermissionTitle, isPresented: $model.openSettingsURL, actions: {
                Button(Loc.Alert.CameraPermissions.settings, role: .cancel, action: { model.onSettingsTap() })
                Button(Loc.cancel, action: {})
            }, message: {
                Text(verbatim: Loc.Alert.CameraPermissions.goToSettings)
            })
            .ifLet(model.errorText) { view, errorText in
                view.alertView(isShowing: $model.showError, errorText: errorText)
            }
            .onAppear {
                model.onAppear()
            }
            .customBackSwipe {
                guard !model.loadingRoute.isLoadingInProgress else { return }
                presentationMode.dismiss()
            }
            .fitIPadToReadableContentGuide()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            Spacer.fixedHeight(16)
            
            PhraseTextView(
                text: $model.phrase,
                noninteractive: false,
                alignTextToCenter: false,
                hideWords: false
            )
            .focused($model.autofocus)
            .disabled(model.loadingRoute.isLoadingInProgress)
            
            Spacer.fixedHeight(16)

            buttonsBlock
            
            Spacer()
        }
    }
    
    private var buttonsBlock : some View {
        VStack(spacing: 12) {
            StandardButton(
                Loc.Auth.LoginFlow.Enter.title,
                inProgress: model.loadingRoute.isLoginInProgress,
                style: .primaryLarge,
                action: {
                    model.onEnterButtonAction()
                }
            )
            .colorScheme(model.loginButtonDisabled ? .dark : .light)
            .disabled(model.loginButtonDisabled)
            
            AnytypeText(
                Loc.Auth.LoginFlow.or,
                style: .caption2Medium
            )
            .foregroundColor(.Auth.inputText)
            
            HStack(spacing: 8) {
                StandardButton(
                    Loc.scanQRCode,
                    inProgress: model.loadingRoute.isQRInProgress,
                    style: .secondaryLarge,
                    action: {
                        model.onScanQRButtonAction()
                    }
                )
                .disabled(model.qrButtonDisabled)
                
                if model.canRestoreFromKeychain {
                    StandardButton(
                        Loc.Auth.LoginFlow.Use.Keychain.title,
                        inProgress: model.loadingRoute.isKeychainInProgress,
                        style: .secondaryLarge,
                        action: {
                            model.onKeychainButtonAction()
                        }
                    )
                    .disabled(model.keychainButtonDisabled)
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
        .disabled(model.loadingRoute.isLoadingInProgress)
    }
}


struct LoginView_Previews : PreviewProvider {
    static var previews: some View {
        LoginView(output: nil)
    }
}
