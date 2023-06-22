import SwiftUI

struct KeyPhraseView: View {
    
    @ObservedObject var model: KeyPhraseViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
            Spacer()
            buttons
        }
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            AnytypeText(Loc.Auth.JoinFlow.Key.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            
            phraseTextView
            
            if model.keyShown {
                StandardButton(
                    Loc.Auth.JoinFlow.Key.Button.Copy.title,
                    style: .secondarySmall,
                    action: {
                        model.onCopyButtonTap()
                    }
                )
            }
            
            AnytypeText(
                model.keyShown ? Loc.Auth.JoinFlow.Key.Shown.description : Loc.Auth.JoinFlow.Key.Hidden.description,
                style: .authBody,
                color: .Auth.body
            )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
    
    private var phraseTextView: some View {
        PhraseTextView(text: $model.key, expandable: true)
            .disabled(true)
            .blur(radius: model.keyShown ? 0 : 5)
            .clipped()
    }
    
    private var buttons: some View {
        VStack(spacing: 12) {
            StandardButton(
                model.keyShown ? Loc.Auth.JoinFlow.Key.Button.Saved.title : Loc.Auth.JoinFlow.Key.Button.Show.title,
                style: .primaryLarge,
                action: {
                    model.onPrimaryButtonTap()
                }
            )
            .colorScheme(.light)
            
            if !model.keyShown {
                StandardButton(
                    Loc.Auth.JoinFlow.Key.Button.Later.title,
                    style: .secondaryLarge,
                    action: {
                        model.onSecondaryButtonTap()
                    }
                )
            }
        }
    }
}


struct KeyView_Previews : PreviewProvider {
    static var previews: some View {
        KeyPhraseView(
            model: KeyPhraseViewModel(
                state: JoinFlowState(),
                output: nil,
                alertOpener: DI.preview.uihelpersDI.alertOpener(),
                localAuthService: DI.preview.serviceLocator.localAuthService()
            )
        )
    }
}
