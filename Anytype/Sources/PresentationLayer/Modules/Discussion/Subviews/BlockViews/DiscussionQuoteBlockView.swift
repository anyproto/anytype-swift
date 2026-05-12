import SwiftUI

struct DiscussionQuoteBlockView: View {

    let content: AttributedString

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.Shape.transparentSecondary)
                .frame(width: 4)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 22)
    }
}
