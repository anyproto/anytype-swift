import SwiftUI
import AnytypeCore
import AudioToolbox

struct AuthView: View {
    
    @StateObject private var model: AuthViewModel
    @State private var safariUrl: URL?
    
    init(output: AuthViewModelOutput?) {
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
        .background(TransparentBackground())
        .fitIPadToReadableContentGuide()
        .preferredColorScheme(.dark)
        .safariSheet(url: $safariUrl, preferredColorScheme: .dark)
    }
    
    private var greetings: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(asset: .localInternet)
                .onTapGesture(count: 10) {
                    AudioServicesPlaySystemSound(1109)
                    model.showDebugMenu.toggle()
                }
                .sheet(isPresented: $model.showDebugMenu) {
                    DebugMenuView()
                }
            
            Spacer.fixedHeight(20)
            
            AnytypeText(
                Loc.Auth.Welcome.subtitle(AboutApp.anyprotoLink),
                style: .uxCalloutRegular,
                enableMarkdown: true
            )
            .foregroundColor(.Auth.body)
            .accentColor(.Auth.inputText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, UIDevice.isPad ? 85 : 38)
            .environment(\.openURL, OpenURLAction { url in
                safariUrl = url
                return .handled
            })
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Button {
                model.showSettings.toggle()
            } label: {
                Image(asset: .NavigationBase.settings)
                    .foregroundColor(.Button.active)
            }
        }
        .sheet(isPresented: $model.showSettings) {
            model.onSettingsAction()
        }
    }

    private var buttons: some View {
        VStack(spacing: 12) {
            StandardButton(
                Loc.Auth.Button.join,
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
            Loc.Auth.Caption.Privacy.text(AboutApp.termsLink, AboutApp.privacyPolicyLink),
            style: .authCaption,
            enableMarkdown: true
        )
        .foregroundColor(.Auth.caption)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 38)
        .accentColor(.Auth.body)
        .environment(\.openURL, OpenURLAction { url in
            safariUrl = url
            return .handled
        })
    }
}

struct AuthView_Previews : PreviewProvider {
    static var previews: some View {
        AuthView(output: nil)
    }
}
