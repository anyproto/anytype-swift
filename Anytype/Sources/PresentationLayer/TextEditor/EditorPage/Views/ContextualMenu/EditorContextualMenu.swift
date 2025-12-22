import SwiftUI

enum EditorContextualOption: Int, Identifiable {
    var id: RawValue { rawValue }

    case createBookmark
    case pasteAsText
    case pasteAsLink

    var localisedString: String {
        switch self {
        case .createBookmark:
            return Loc.LinkPaste.bookmark
        case .pasteAsText:
            return Loc.LinkPaste.text
        case .pasteAsLink:
            return Loc.LinkPaste.link
        }
    }
}

struct EditorContextualMenuView: View {
    let options: [EditorContextualOption]
    let optionTapHandler: (EditorContextualOption) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer.fixedHeight(12)
            ForEach(options) { option in
                Button {
                    optionTapHandler(option)
                } label: {
                    HStack {
                        Text(verbatim: option.localisedString)
                            .frame(alignment: .leading)
                            .foregroundStyle(Color.Text.primary)
                            .font(AnytypeFontBuilder.font(anytypeFont: .bodyRegular))
                            .padding(.vertical, 9)
                            .padding(.leading, 24)
                            .fixTappableArea()
                        Spacer()
                    }
                }
                .frame(width: 252, height: 40)
                .buttonStyle(TertiaryPressedBackgroundButtonStyle())
            }
            Spacer.fixedHeight(12)
        }
    }
}
