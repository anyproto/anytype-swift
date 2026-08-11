import SwiftUI

struct ChatSearchResultRow: View {

    let data: ChatMessageSearchResultData
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            content
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        HStack(alignment: .center, spacing: 12) {
            IconView(icon: data.authorIcon)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 8) {
                    AnytypeText(data.authorName, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer()
                    AnytypeText(data.dateText, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }
                Text(data.snippet)
                    .anytypeStyle(.relation2Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
        .fixTappableArea()
    }
}
