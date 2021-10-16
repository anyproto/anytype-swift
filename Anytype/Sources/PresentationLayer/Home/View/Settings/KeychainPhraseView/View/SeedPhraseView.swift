import SwiftUI

struct SeedPhraseView: View {
    @Binding var phrase: String?
    
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center) {
                AnytypeText(phrase ?? RedactedText.seedPhrase.localized, style: .codeBlock, color: .darkBlue)
                    .redacted(reason: phrase.isNil ? .placeholder : [])
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            .background(Color.grayscale10)
            .cornerRadius(4)
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    static var previews: some View {
        SeedPhraseView(
            phrase: .constant(
                "witch collapse practice feed shame open despair creek road again ice least lake tree young address brain despair"
            ),
            onTap: {}
        )
            .padding()
    }
}

