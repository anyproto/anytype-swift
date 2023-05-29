import SwiftUI

struct KeyPhraseView: View {
    
    @ObservedObject var model: KeyPhraseViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            AnytypeText(Loc.Auth.JoinFlow.Key.title, style: .uxTitle1Semibold, color: .Text.primary)
                .opacity(0.9)
            
            Spacer.fixedHeight(16)
            
           // MultilineTextField
            
            Spacer.fixedHeight(16)
            
            AnytypeText(Loc.Auth.JoinFlow.Key.description, style: .authBoby, color: .Auth.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Spacer()
            
            buttons
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 0) {
            StandardButton(
                Loc.Auth.JoinFlow.Key.Button.Show.title,
                style: .primaryLarge,
                action: {}
            )
            .colorScheme(.light)
            
            Spacer.fixedHeight(12)
            
            StandardButton(
                Loc.Auth.JoinFlow.Key.Button.Later.title,
                style: .secondaryLarge,
                action: {
                    model.onNextButtonTap()
                }
            )
        }
    }
}


struct KeyView_Previews : PreviewProvider {
    static var previews: some View {
        KeyPhraseView(model: KeyPhraseViewModel(output: nil))
    }
}
