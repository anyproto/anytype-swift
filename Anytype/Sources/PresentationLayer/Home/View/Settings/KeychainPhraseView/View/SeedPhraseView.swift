import SwiftUI

struct SeedPhraseView: View {
    
    @ObservedObject var model: KeychainPhraseViewModel
    let onTap: () -> ()
    
    var body: some View {
        Button(action: { model.onSeedViewTap(onTap: onTap) }) {
            VStack(alignment: .leading) {
                Spacer.fixedHeight(10)
                AnytypeText(
                    model.recoveryPhrase ?? Loc.KeychainPhrase.seedPhrasePlaceholder,
                    style: .codeBlock,
                    color: .Text.sky
                )
                    .redacted(reason: model.recoveryPhrase.isNil ? .placeholder : [])
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                Spacer.fixedHeight(10)
            }
            .background(Color.strokeTransperent)
            .cornerRadius(4)
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(model: KeychainPhraseViewModel(), onTap: {}).padding()
    }
}

