import SwiftUI

struct SeedPhraseView: View {
    @Binding var phrase: String?
    
    let onTap: () -> Void
    private let redactedPlaceholder = "You Take The Red Pill - You Stay In Wonderland, And I Show You How Deep The Rabbit Hole Goes"

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center) {
                AnytypeText(phrase ?? redactedPlaceholder, style: .codeBlock)
                    .foregroundColor(Color.darkBlue)
                    .redacted(reason: phrase.isNil ? .placeholder : [])
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .background(Color.grayscale10)
            .cornerRadius(4)
        }
    }
}
