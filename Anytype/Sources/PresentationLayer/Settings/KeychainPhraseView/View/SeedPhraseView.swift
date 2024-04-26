import SwiftUI

struct SeedPhraseView: View {
    
    @ObservedObject var model: KeychainPhraseViewModel
    
    var body: some View {
        Button(action: { model.onSeedViewTap() }) {
            HStack {
                AnytypeText(
                    model.recoveryPhrase ?? Loc.Keychain.seedPhrasePlaceholder,
                    style: .codeBlock
                )
                    .foregroundColor(.Dark.sky)
                    .redacted(reason: model.recoveryPhrase.isNil ? .placeholder : [])
                    .multilineTextAlignment(.leading)
                if model.recoveryPhrase.isNotNil {
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.Shape.transperent)
            .cornerRadius(4)
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(model: KeychainPhraseViewModel(shownInContext: .logout)).padding()
    }
}

