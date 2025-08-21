import SwiftUI
import AnytypeCore
import AudioToolbox

struct PrimaryAuthView: View {
    
    @StateObject private var model: PrimaryAuthViewModel
    
    init(output: (any PrimaryAuthOutput)?) {
        _model = StateObject(wrappedValue: PrimaryAuthViewModel(output: output))
    }
    
    var body: some View {
        content
            .onAppear {
                model.onAppear()
            }
            .task(item: model.createAccountTaskId) { _ in
                await model.createAccount()
            }
            .ifLet(model.errorText) { view, errorText in
                view.alertView(isShowing: $model.showError, errorText: errorText, onButtonTap: {})
            }
    }
    
    private var content: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            Group {
                Spacer()
                greetings
                Spacer()
                buttons
                Spacer.fixedHeight(24)
                privacyPolicy
                Spacer.fixedHeight(12)
            }
            .padding(.horizontal, 20)
        }
        .fitIPadToReadableContentGuide()
    }

    private var greetings: some View {
        Group {
            (
                Text(Loc.Auth.Primary.Greeting.pt1)
                    .foregroundColor(.Text.primary)
                    .anytypeFontStyle(.interTitle)
                +
                Text("\n")
                    .anytypeFontStyle(.riccioneTitle)
                +
                Text(Loc.Auth.Primary.Greeting.pt2)
                    .foregroundColor(.Text.secondary)
                    .anytypeFontStyle(.riccioneTitle)
             )
            .multilineTextAlignment(.center)
        }
        .anytypeLineHeightStyle(.interTitle)
        .onTapGesture(count: 10) {
            AudioServicesPlaySystemSound(1109)
            model.onDebugMenuTap()
        }
            
    }
    
    private var header: some View {
        ModalNavigationHeader {
            EmptyView()
        } titleView: {
            Image(asset: .logo)
                .foregroundColor(.Control.primary)
        } rightView: {
            Button {
                model.onSettingsButtonTap()
            } label: {
                Image(asset: .X24.spaceSettings)
                    .foregroundColor(.Control.secondary)
            }
            .disabled(model.inProgress)
        }
    }

    private var buttons: some View {
        VStack(spacing: 8) {
            StandardButton(
                Loc.Auth.Button.join,
                inProgress: model.inProgress,
                style: .primaryLarge,
                action: {
                    model.onJoinButtonTap()
                }
            )
            
            StandardButton(
                Loc.Auth.logIn,
                style: .secondaryLarge,
                action: {
                    model.onLoginButtonTap()
                }
            )
            .disabled(model.inProgress)
        }
    }
    
    private var privacyPolicy: some View {
        AnytypeText(
            Loc.agreementDisclamer(AboutApp.termsLink, AboutApp.privacyPolicyLink),
            style: .relation3Regular,
            enableMarkdown: true
        )
        .foregroundColor(.Text.secondary)
        .multilineTextAlignment(.center)
        .accentColor(.Text.secondary)
        .disabled(model.inProgress)
    }
}
