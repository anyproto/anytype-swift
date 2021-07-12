import SwiftUI

struct SeedPhraseView: View {
    @Binding var phrase: String?
    
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center) {
                AnytypeText(phrase ?? RedactedText.seedPhrase, style: .codeBlock)
                    .foregroundColor(Color.darkBlue)
                    .redacted(reason: phrase.isNil ? .placeholder : [])
                    .padding()
                    .autocapitalization(.none)
            }
            .frame(maxWidth: .infinity)
            .background(Color.grayscale10)
            .cornerRadius(4)
        }
    }
}
