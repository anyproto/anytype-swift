import SwiftUI

struct KeyPhraseView: View {
    
    @StateObject var model: KeyPhraseViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            content
            Spacer()
            buttons
        }
        .onAppear {
            model.onAppear()
        }
        .sheet(isPresented: $model.showMoreInfo) {
            model.keyPhraseMoreInfo()
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Key.title, style: .heading, color: .Auth.inputText)
                .multilineTextAlignment(.center)
            
            Spacer.fixedHeight(12)
            
            AnytypeText(
                Loc.Auth.JoinFlow.Key.description,
                style: .calloutRegular,
                color: .Auth.body
            )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer.fixedHeight(4)
            
            AnytypeText(Loc.Auth.JoinFlow.Key.Button.Info.title, style: .uxBodyRegular, color: .Auth.inputText)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    model.showMoreInfo.toggle()
                }
            
            Spacer.fixedHeight(12)
            
            phraseTextView
            
            if model.keyShown {
                Spacer.fixedHeight(12)
                StandardButton(
                    Loc.Auth.JoinFlow.Key.Button.Copy.title,
                    style: .secondarySmall,
                    action: {
                        model.onCopyButtonTap()
                    }
                )
            }
        }
        .padding(.horizontal, UIDevice.isPad ? 75 : 0)
    }
    
    private var phraseTextView: some View {
        PhraseTextView(
            text: $model.key,
            noninteractive: true,
            alignTextToCenter: true,
            hideWords: !model.keyShown
        )
        .disabled(true)
        .blur(radius: model.keyShown ? 0 : 5)
        .clipped()
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            if !model.keyShown {
                AnytypeText(Loc.Auth.JoinFlow.Key.Button.Tip.title, style: .caption1Regular, color: .Auth.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                Spacer.fixedHeight(18)
            }

            StandardButton(model.keyShown ? Loc.Auth.JoinFlow.Key.Button.Saved.title : Loc.Auth.JoinFlow.Key.Button.Show.title,
                style: .primaryLarge,
                action: {
                    model.onPrimaryButtonTap()
                }
            )
            .colorScheme(.light)
            
            if !model.keyShown {
                Spacer.fixedHeight(13)
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
                alertOpener: DI.preview.uihelpersDI.alertOpener()
            )
        )
    }
}
