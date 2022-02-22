import BlocksModels

struct BeginingOfTextMarkdown {
    let text: [String]
    let style: BlockText.Style
}

extension BeginingOfTextMarkdown {
    init(text: String, style: BlockText.Style) {
        self.init(text: [text], style: style)
    }
}

extension BeginingOfTextMarkdown {
    static let all: [BeginingOfTextMarkdown] = [
        BeginingOfTextMarkdown(text: "# ", style: .header),
        BeginingOfTextMarkdown(text: "## ", style: .header2),
        BeginingOfTextMarkdown(text: "### ", style: .header3),
        BeginingOfTextMarkdown(text: ["\" ", "\' ", "“ ", "‘ "], style: .quote),
        BeginingOfTextMarkdown(text: ["* ", "- ", "+ "], style: .bulleted),
        BeginingOfTextMarkdown(text: "[] ", style: .checkbox),
        BeginingOfTextMarkdown(text: "1. ", style: .numbered),
        BeginingOfTextMarkdown(text: "> ", style: .toggle),
        BeginingOfTextMarkdown(text: ["``` ", "““ ", "‘‘‘ "], style: .code),
    ]
}
