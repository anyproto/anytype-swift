import SwiftUI

struct AuthView: View {
    
    @ObservedObject var model: AuthViewModel
    
    var body: some View {
        AuthBackgroundView(url: model.videoUrl()) {
            content
                .navigationBarHidden(true)
                .opacity(model.opacity)
                .onAppear {
                    model.onViewAppear()
                }
                .background(TransparentBackground())
                .fitIPadToReadableContentGuide()
                .preferredColorScheme(.dark)
        }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            greetings
            Spacer()
            buttons
            Spacer.fixedHeight(16)
            privacyPolicy
            Spacer.fixedHeight(14)
        }
        .padding(.horizontal, 30)
        .ifLet(model.errorText) { view, errorText in
            view.errorToast(isShowing: $model.showError, errorText: errorText)
        }
    }
    
    private var greetings: some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(Loc.Auth.Welcome.title, style: .authTitle, color: .Text.primary)
                .multilineTextAlignment(.center)
                .opacity(0.9)
                .onTapGesture(count: 10) {
                    model.showDebugMenu.toggle()
                }
                .sheet(isPresented: $model.showDebugMenu) {
                    model.onDebugMenuAction()
                }
            
            Spacer.fixedHeight(30)
            
            AnytypeText(Loc.Auth.Welcome.subtitle, style: .authBody, color: .Auth.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
        }
    }

    private var buttons: some View {
        HStack(spacing: 13) {
            StandardButton(
                Loc.Auth.join,
                inProgress: model.creatingAccountInProgress,
                style: .primaryLarge,
                action: {
                    model.onJoinButtonTap()
                }
            )
            .colorScheme(.light)
            .addEmptyNavigationLink(destination: model.onJoinAction(), isActive: $model.showJoinFlow)
            
            StandardButton(
                Loc.Auth.logIn,
                style: .secondaryLarge,
                action: {
                    model.onLoginButtonTap()
                }
            )
            .addEmptyNavigationLink(destination: model.onLoginAction(), isActive: $model.showLoginFlow)
        }
    }
    
    private var privacyPolicy: some View {
        AnytypeText(
            Loc.Auth.Caption.Privacy.text(AboutApp.termsLink, AboutApp.privacyLink),
            style: .authCaption,
            color: .Auth.caption
        )
        .multilineTextAlignment(.center)
        .padding(.horizontal, 28)
        .accentColor(.Text.secondary)
        .environment(\.openURL, OpenURLAction { url in
            model.onUrlTapAction(url)
            return .handled
        })
    }
}

struct AuthView_Previews : PreviewProvider {
    static var previews: some View {
        AuthView(
            model: AuthViewModel(
                state: JoinFlowState(),
                output: nil,
                authService: DI.preview.serviceLocator.authService(),
                seedService: DI.preview.serviceLocator.seedService(),
                metricsService: DI.preview.serviceLocator.metricsService(),
                usecaseService: DI.preview.serviceLocator.usecaseService()
            )
        )
    }
}
