import SwiftUI
import AnytypeCore
import AudioToolbox

struct AuthView: View {
    
    @StateObject private var model: AuthViewModel
    
    init(output: (any AuthViewModelOutput)?) {
        _model = StateObject(wrappedValue: AuthViewModel(output: output))
    }
    
    var body: some View {
        AuthBackgroundView(url: model.videoUrl()) {
            content
        }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            Spacer.fixedHeight(48)
            Spacer()
            greetings
            Spacer()
            buttons
            Spacer.fixedHeight(16)
            privacyPolicy
            Spacer.fixedHeight(14)
        }
        .padding(.horizontal, 20)
        .ignoresSafeArea(.keyboard)
        .navigationBarHidden(true)
        .opacity(model.opacity)
        .onAppear {
            model.onAppear()
        }
        .disablePresentationBackground()
        .ifLet(model.errorText) { view, errorText in
            view.alertView(isShowing: $model.showError, errorText: errorText, onButtonTap: {})
        }
        .fitIPadToReadableContentGuide()
    }
    
    @ViewBuilder
    private var greetings: some View {
        Image(asset: .greetings)
            .onTapGesture(count: 10) {
                AudioServicesPlaySystemSound(1109)
                model.showDebugMenu.toggle()
            }
            .sheet(isPresented: $model.showDebugMenu) {
                DebugMenuView()
            }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Button {
                model.showSettings.toggle()
            } label: {
                Image(asset: .NavigationBase.settings)
                    .foregroundColor(.Control.secondary)
            }
            .disabled(model.inProgress)
        }
        .sheet(isPresented: $model.showSettings) {
            model.onSettingsAction()
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            StandardButton(
                Loc.Auth.Button.join,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onJoinButtonTap()
                }
            )
            .colorScheme(.light)
            .navigationDestination(isPresented: $model.showJoinFlow) {
                model.onJoinAction()
            }
            
            StandardButton(
                Loc.Auth.logIn,
                style: .secondaryLarge,
                action: {
                    model.onLoginButtonTap()
                }
            )
            .navigationDestination(isPresented: $model.showLoginFlow) {
                model.onLoginAction()
            }
            .disabled(model.inProgress)
        }
    }
    
    private var privacyPolicy: some View {
        AnytypeText(
            Loc.agreementDisclamer(AboutApp.termsLink, AboutApp.privacyPolicyLink),
            style: .authCaption,
            enableMarkdown: true
        )
        .foregroundColor(.Auth.caption)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 38)
        .accentColor(.Auth.body)
        .disabled(model.inProgress)
    }
}

struct AuthView_Previews : PreviewProvider {
    static var previews: some View {
        AuthView(output: nil)
    }
}
