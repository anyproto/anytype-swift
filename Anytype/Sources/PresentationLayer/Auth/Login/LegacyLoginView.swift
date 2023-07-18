import SwiftUI

struct LegacyLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: LegacyLoginViewModel
    
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
            AlertsFactory.goToSettingsAlert(title: Loc.Auth.cameraPermissionTitle)
        }
        .sheet(isPresented: $viewModel.showQrCodeView) {
            QRCodeScannerView(qrCode: self.$viewModel.entropy, error: self.$viewModel.error)
        }
        .onAppear {
            AnytypeAnalytics.instance().logLoginScreenShow()
        }
        .if(UIDevice.isPad, if: {
            $0.sheet(isPresented: $viewModel.showMigrationGuide) {
                viewModel.migrationGuideFlow()
            }
         }, else: {
            $0.fullScreenCover(isPresented: $viewModel.showMigrationGuide) {
                viewModel.migrationGuideFlow()
            }
         })
    }
    
    private var bottomSheet: some View {
        VStack(spacing: 0) {
            Spacer()
            keychainPhraseView
                .horizontalReadabilityPadding(20)
                .padding(.bottom, 20)
        }
    }

    private var keychainPhraseView: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                AnytypeText(Loc.login, style: .heading, color: .Text.primary)
                Spacer.fixedHeight(19)
                scanQR
                if viewModel.canRestoreFromKeychain {
                    restoreFromKeychain
                }
                enterMnemonic
                buttons
            }
            .padding(EdgeInsets(top: 23, leading: 20, bottom: 10, trailing: 20))
        }
        .background(Color.Background.primary)
        .cornerRadius(16.0)
    }
    
    private var buttons: some View {
        HStack(spacing: 12) {
            StandardButton(.text(Loc.back), style: .secondaryLarge) {
                self.presentationMode.wrappedValue.dismiss()
            }

            StandardButton(.text(Loc.login), style: .primaryLarge) {
                self.viewModel.recoverWallet()
            }
            .disabled(viewModel.seed.isEmpty)
        }
    }
    
    // Workaround for text editor placeholder
    // https://stackoverflow.com/a/62742668/6252099
    private var enterMnemonic: some View {
        ZStack(alignment: .topLeading) {
            if(viewModel.seed.isEmpty) {
                AnytypeText(Loc.orTypeYourRecoveryPhrase, style: .codeBlock, color: .Text.secondary)
                    .padding(.top, 17)
            }
            
            TextEditor(text: $viewModel.seed)
                .focused($viewModel.focusOnTextField)
                .lineLimit(3)
                .font(AnytypeFontBuilder.font(anytypeFont: .codeBlock))
                .lineSpacing(AnytypeFont.codeBlock.lineSpacing)
                .foregroundColor(.Text.primary)
                .padding(.top, 9)
                .padding(.leading, -5)
                .opacity(viewModel.seed.isEmpty ? 0.25 : 1)
                .autocapitalization(.none)
                .frame(height: 124)
                .textContentType(.password)
                .disableAutocorrection(true)
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
                AnytypeText(Loc.scanQRCode, style: .uxBodyRegular, color: .Text.primary)
                Spacer()
                Image(asset: .arrowForward)
            }
            .frame(height: 48)
            .divider()
        }
    }

    private var restoreFromKeychain: some View {
        Button(
            action: {
                UIApplication.shared.hideKeyboard()
                viewModel.restoreFromkeychain()
            }
        ) {
            HStack {
                AnytypeText(Loc.restoreFromKeychain, style: .button1Regular, color: Color.System.amber125)
                Spacer()
                Image(systemName: "key")
                    .foregroundColor(Color.System.amber125)
            }
            .frame(height: 48)
            .divider()
        }
    }
    
    private var loginNavigation: some View {
        NavigationLink(
            destination: viewModel.selectProfileFlow(),
            isActive: $viewModel.showSelectProfile
        ) {
            EmptyView()
        }
    }
}

struct LegacyLoginView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyLoginView(viewModel: LegacyLoginViewModel(applicationStateService: DI.preview.serviceLocator.applicationStateService()))
    }
}
