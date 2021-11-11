import BlocksModels

struct MarkdownShortcut {
    let text: [String]
    let style: BlockText.Style
}

extension MarkdownShortcut {
    init(text: String, style: BlockText.Style) {
        self.init(text: [text], style: style)
    }
}

extension MarkdownShortcut {
    static let beginingOfText: [MarkdownShortcut] = [
        MarkdownShortcut(text: "# ", style: .header),
        MarkdownShortcut(text: "## ", style: .header2),
        MarkdownShortcut(text: "### ", style: .header3),
        MarkdownShortcut(text: ["\" ", "\' ", "“ ", "‘ "], style: .quote),
        MarkdownShortcut(text: ["* ", "- ", "+ "], style: .bulleted),
        MarkdownShortcut(text: "[] ", style: .checkbox),
        MarkdownShortcut(text: "1. ", style: .numbered),
        MarkdownShortcut(text: "> ", style: .toggle),
        MarkdownShortcut(text: "``` ", style: .code),
    ]
}
