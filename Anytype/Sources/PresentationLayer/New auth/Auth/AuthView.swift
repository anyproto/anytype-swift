import SwiftUI

struct AuthView: View {
    
    @ObservedObject var model: AuthViewModel
    
    var body: some View {
        AuthBackgroundView(url: model.videoUrl()) {
            content
                .navigationBarHidden(true)
                .modifier(LogoOverlay())
                .opacity(model.opacity)
                .onAppear {
                    model.onViewAppear()
                }
                .sheet(isPresented: $model.showSafari) {
                    if let currentUrl = model.currentUrl {
                        SafariView(url: currentUrl)
                    }
                }
                .background(TransparentBackground())
                .fitIPadToReadableContentGuide()
        }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            greetings
            Spacer()
            buttons
            Spacer.fixedHeight(16)
            if #available(iOS 15.0, *) {
                privacyPolicy
            }
            Spacer.fixedHeight(14)
        }
        .padding(.horizontal, 30)
    }
    
    private var greetings: some View {
        VStack(alignment: .center, spacing: 0) {
            AnytypeText(Loc.Auth.Welcome.title, style: .authTitle, color: .Text.primary)
                .multilineTextAlignment(.center)
                .opacity(0.9)
            
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
                action: {}
            )
        }
    }
    
    @available(iOS 15.0, *)
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
                viewControllerProvider: DI.preview.uihelpersDI.viewControllerProvider(),
                output: nil,
                authService: DI.preview.serviceLocator.authService(),
                seedService: DI.preview.serviceLocator.seedService()
            )
        )
    }
}
