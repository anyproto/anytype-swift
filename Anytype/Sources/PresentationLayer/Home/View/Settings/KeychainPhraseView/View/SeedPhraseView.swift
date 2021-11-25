import SwiftUI

struct SeedPhraseView: View {
    @StateObject private var model = KeychainPhraseViewModel()
    
    let onTap: () -> ()
    
    var body: some View {
        Button(action: { model.onSeedViewTap(onTap: onTap) }) {
            VStack(alignment: .center) {
                AnytypeText(model.recoveryPhrase ?? RedactedText.seedPhrase.localized, style: .codeBlock, color: .darkBlue)
                    .redacted(reason: model.recoveryPhrase.isNil ? .placeholder : [])
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            .background(Color.grayscale10)
            .cornerRadius(4)
        }
        .onAppear {
            model.obtainRecoveryPhrase()
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(onTap: {}).padding()
    }
}

