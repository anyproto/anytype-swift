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
                .frame(maxWidth: .infinity, alignment: .leading)
        case .toggle(_, let content):
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.Text.secondary)
                    .font(.caption)
                    .frame(width: 20, height: 20)
                Text(content)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .callout(_, let content):
            Text(content)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Background.secondary)
                .clipShape(.rect(cornerRadius: 8))
        case .quote(_, let content):
            DiscussionQuoteBlockView(content: content)
        case .checkbox(_, let content, let checked):
            DiscussionCheckboxBlockView(content: content, checked: checked)
        case .bulleted(_, let content):
            DiscussionBulletedBlockView(content: content)
        case .numbered(_, let content, let number):
            DiscussionNumberedBlockView(content: content, number: number)
        case .divider:
            DiscussionDividerBlockView()
        case .image(_, let details), .video(_, let details):
            MessageGridAttachmentsContainer(objects: [details], spacing: 0) { attachment in
                onTapAttachment?(attachment.id)
            }
        case .file(_, let details), .linkObject(_, let details):
            Button { onTapAttachment?(details.id) } label: {
                DiscussionFileBlockView(details: details)
            }
            .buttonStyle(.plain)
        case .bookmark(_, let details):
            Button { onTapAttachment?(details.id) } label: {
                DiscussionBookmarkBlockView(details: details)
            }
            .buttonStyle(.plain)
        case .embed(_, let data):
            DiscussionEmbedBlockView(data: data)
        case .unsupported(_, let blockName):
            DiscussionUnsupportedBlockView(blockName: blockName)
        }
    }
}
