import SwiftUI

struct SeedPhraseView: View {
    
    @ObservedObject var model: KeychainPhraseViewModel
    let onTap: () -> ()
    
    var body: some View {
        Button(action: { model.onSeedViewTap(onTap: onTap) }) {
            HStack {
                AnytypeText(
                    model.recoveryPhrase ?? Loc.Keychain.seedPhrasePlaceholder,
                    style: .codeBlock,
                    color: .Dark.sky
                )
                    .redacted(reason: model.recoveryPhrase.isNil ? .placeholder : [])
                    .multilineTextAlignment(.leading)
                if model.recoveryPhrase.isNotNil {
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.Stroke.transperent)
            .cornerRadius(4)
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(model: KeychainPhraseViewModel(), onTap: {}).padding()
    }
}

