import SwiftUI

struct DiscussionBlockItemView: View {

    let block: DiscussionBlockItem

    var body: some View {
        switch block {
        case .text(_, let content):
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
                .cornerRadius(8)
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
        case .numbered(_, let content):
            HStack(alignment: .top, spacing: 6) {
                Text("\(block.id + 1).")
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
        case .unsupported(_, let blockName):
            Text("UNSUPPORTED: \(blockName)")
                .foregroundStyle(Color.Pure.red)
                .padding(.vertical, 2)
        }
    }
}
