import SwiftUI

struct DiscussionNumberedBlockView: View {

    let content: AttributedString
    let number: Int

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(number).")
                .anytypeStyle(.calloutRegular)
                .foregroundStyle(Color.Text.primary)
                .frame(width: 20, height: 20)
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
