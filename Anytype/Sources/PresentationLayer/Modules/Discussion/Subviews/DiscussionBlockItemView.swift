import SwiftUI
import Services

struct DiscussionBlockItemView: View {

    let block: DiscussionBlockItem
    let onTapAttachment: ((String) -> Void)?

    init(block: DiscussionBlockItem, onTapAttachment: ((String) -> Void)? = nil) {
        self.block = block
        self.onTapAttachment = onTapAttachment
    }

    var body: some View {
        switch block {
        case .text(_, let content),
             .title(_, let content),
             .heading(_, let content),
             .subheading(_, let content):
            Text(content)
                .padding(.vertical, 2)
        case .quote(_, let content):
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.Text.secondary)
                    .frame(width: 2)
                Text(content)
            }
            .padding(.vertical, 2)
        case .callout(_, let content):
            Text(content)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Background.secondary)
                .clipShape(.rect(cornerRadius: 8))
                .padding(.vertical, 2)
        case .checkbox(_, let content, let checked):
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: checked ? "checkmark.square" : "square")
                    .foregroundStyle(Color.Text.secondary)
                Text(content)
            }
            .padding(.vertical, 2)
        case .bulleted(_, let content):
            HStack(alignment: .top, spacing: 6) {
                Text("\u{2022}")
                    .foregroundStyle(Color.Text.secondary)
                Text(content)
            }
            .padding(.vertical, 2)
        case .numbered(_, let content, let number):
            HStack(alignment: .top, spacing: 6) {
                Text("\(number).")
                    .foregroundStyle(Color.Text.secondary)
                Text(content)
            }
            .padding(.vertical, 2)
        case .toggle(_, let content):
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.Text.secondary)
                    .font(.caption)
                Text(content)
            }
            .padding(.vertical, 2)
        case .image(_, let details), .video(_, let details):
            MessageGridAttachmentsContainer(objects: [details], spacing: 0) { attachment in
                onTapAttachment?(attachment.id)
            }
            .padding(.vertical, 2)
        case .file(_, let details), .linkObject(_, let details):
            Button { onTapAttachment?(details.id) } label: {
                DiscussionFileBlockView(details: details)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)
        case .bookmark(_, let details):
            Button { onTapAttachment?(details.id) } label: {
                DiscussionBookmarkBlockView(details: details)
            }
            .buttonStyle(.plain)
            .padding(.vertical, 2)
        case .embed(_, let data):
            DiscussionEmbedBlockView(data: data)
                .padding(.vertical, 2)
        case .divider:
            Color.Shape.primary
                .frame(height: 1)
                .padding(.vertical, 10)
        case .unsupported(_, let blockName):
            DiscussionUnsupportedBlockView(blockName: blockName)
                .padding(.vertical, 2)
        }
    }
}
