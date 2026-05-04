import SwiftUI

enum EditorContextualOption: Int, Identifiable {
    var id: RawValue { rawValue }

    case object
    case createBookmark
    case pasteAsLink
    case pasteAsText

    var localisedString: String {
        switch self {
        case .object:
            return Loc.PasteMenu.object
        case .createBookmark:
            return Loc.PasteMenu.bookmark
        case .pasteAsLink:
            return Loc.PasteMenu.url
        case .pasteAsText:
            return Loc.PasteMenu.plainText
        }
    }

    var systemImageName: String {
        switch self {
        case .object:
            return "doc.text"
        case .createBookmark:
            return "bookmark"
        case .pasteAsLink:
            return "link"
        case .pasteAsText:
            return "text.alignleft"
        }
    }
}

struct EditorContextualMenuView: View {
    let options: [EditorContextualOption]
    let optionTapHandler: (EditorContextualOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(12)
            header
            ForEach(options) { option in
                Button {
                    optionTapHandler(option)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: option.systemImageName)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.Text.primary)
                        Text(verbatim: option.localisedString)
                            .foregroundStyle(Color.Text.primary)
                            .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
                            .padding(.vertical, 9)
                            .fixTappableArea()
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                }
                .frame(width: 252, height: 40)
                .buttonStyle(TertiaryPressedBackgroundButtonStyle())
            }
            Spacer.fixedHeight(12)
        }
    }

    private var header: some View {
        Text(verbatim: Loc.PasteMenu.header)
            .font(AnytypeFontBuilder.font(anytypeFont: .caption1Medium))
            .foregroundStyle(Color.Text.secondary)
            .padding(.horizontal, 24)
            .frame(height: 28, alignment: .leading)
    }
}
