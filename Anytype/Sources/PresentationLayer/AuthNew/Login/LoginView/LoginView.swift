import SwiftUI
import AnytypeCore
import AudioToolbox

struct LoginView: View {
    
    @StateObject private var model: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(output: (any LoginOutput)?) {
        _model = StateObject(wrappedValue: LoginViewModel(output: output))
    }
    
    var body: some View {
        content
            .toolbar(.hidden)
            .fixTappableArea()
            .customBackSwipe {
                guard !model.backButtonDisabled else { return }
                dismiss()
            }
        
            .onAppear {
                model.onAppear()
            }
            .task(item: model.walletRecoveryTaskId) { _ in
                await model.walletRecovery()
            }
            .task(item: model.accountId) { _ in
                await model.selectAccount()
            }
            .task(item: model.entropy) { _ in
                await model.onEntropySet()
            }
            .task {
                await model.handleAccountShowEvent()
            }
            .task(item: model.logoutTaskId) { _ in
                await model.logout()
            }
        
            .ifLet(model.errorText) { view, errorText in
                view.alertView(isShowing: $model.showError, errorText: errorText)
            }
            .fitIPadToReadableContentGuide()
            .onChange(of: model.dismiss) { dismiss() }
    }
    
    private var header: some View {
        ModalNavigationHeader {
            backButton
        } titleView: {
            Image(asset: .logo)
                .foregroundColor(.Control.primary)
                .onTapGesture(count: 5) {
                    AudioServicesPlaySystemSound(1109)
                    model.openPublicDebugMenuTap()
                }
        } rightView: {
            EmptyView()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            
            Group {
                Spacer.fixedHeight(24)
                
                PhraseTextView(
                    text: $model.phrase,
                    noninteractive: false,
                    alignTextToCenter: false,
                    hideWords: false
                )
                .focused(.constant(true))
                .disabled(model.loadingInProgress)
                
                Spacer.fixedHeight(12)

                buttonsBlock
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var buttonsBlock : some View {
        VStack(spacing: 24) {
            StandardButton(
                Loc.enter,
                inProgress: model.loadingInProgress,
                style: .primaryLarge,
                action: {
                    model.onEnterButtonAction()
                }
            )
            .disabled(model.phrase.isEmpty)
            
            AnytypeText(
                Loc.Auth.Login.Or.title,
                style: .caption1Regular
            )
            .foregroundColor(.Text.secondary)
            
            HStack(spacing: 44) {
                Spacer()
                
                AsyncButton {
                    await model.onScanQRButtonAction()
                } label: {
                    actionView(asset: .X24.qrCode, title: Loc.qrCode)
                }
                .disabled(model.loadingInProgress)
                
                if model.canRestoreFromKeychain {
                    AsyncButton {
                        try await model.onKeychainButtonAction()
                    } label: {
                        actionView(asset: .X24.keychain, title: Loc.keychain)
                    }
                    .disabled(model.loadingInProgress)
                }
                Spacer()
            }
        }
    }
    
    private var backButton : some View {
        Button(action: {
            model.onbackButtonAction()
        }) {
            Image(asset: .X24.back)
                .foregroundColor(.Control.secondary)
        }
        .disabled(model.backButtonDisabled)
    }
    
    private func actionView(asset: ImageAsset, title: String) -> some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(Color.Shape.transperentSecondary)
                    .frame(width: 56, height: 56)
                Image(asset: asset)
                    .foregroundStyle(Color.Control.primary)
                    .frame(width: 24, height: 24)
            }
            
            Spacer.fixedHeight(8)
            
            AnytypeText(title, style: .caption2Regular)
                .foregroundColor(.Text.primary)
        }
        .fixTappableArea()
    }
}
