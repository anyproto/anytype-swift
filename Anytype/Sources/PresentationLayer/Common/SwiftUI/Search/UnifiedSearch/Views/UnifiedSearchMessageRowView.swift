import SwiftUI
import Services

struct UnifiedSearchMessageRow: Identifiable, Hashable {
    let messageId: String
    let chatObjectId: String
    let spaceId: String
    let authorIcon: Icon
    let authorName: String
    let snippet: AttributedString
    let dateText: String
    // The chat or thread-parent page the message lives in; nil when unresolvable
    let containerName: String?
    let spaceCaption: SearchSpaceCaption?

    var id: String { messageId }
}

struct UnifiedSearchMessageRowView: View {

    let row: UnifiedSearchMessageRow
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
            IconView(icon: row.authorIcon)
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 8) {
                    AnytypeText(row.authorName, style: .previewTitle2Medium)
                        .foregroundStyle(Color.Text.primary)
                        .lineLimit(1)
                    Spacer()
                    AnytypeText(row.dateText, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }
                Text(row.snippet)
                    .anytypeStyle(.relation2Regular)
                    .foregroundStyle(Color.Text.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                caption
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .newDivider(leadingPadding: 16, trailingPadding: 16)
        .fixTappableArea()
    }

    @ViewBuilder
    private var caption: some View {
        if row.containerName.isNotNil || row.spaceCaption.isNotNil {
            HStack(spacing: 4) {
                if let containerName = row.containerName {
                    AnytypeText(containerName, style: .relation2Regular)
                        .foregroundStyle(Color.Text.secondary)
                        .lineLimit(1)
                }
                if let spaceCaption = row.spaceCaption {
                    if row.containerName.isNotNil {
                        AnytypeText("·", style: .relation2Regular)
                            .foregroundStyle(Color.Text.secondary)
                    }
                    spaceCaptionView(spaceCaption)
                }
            }
        }
    }

    private func spaceCaptionView(_ spaceCaption: SearchSpaceCaption) -> some View {
        AnytypeText(Loc.UnifiedSearch.inSpace(spaceCaption.name), style: .relation2Regular)
            .foregroundStyle(Color.Text.secondary)
            .lineLimit(1)
    }
}
