import Services

struct BeginingOfTextMarkdown {
    let text: [String]
    let type: BlockContentType
}

extension BeginingOfTextMarkdown {
    init(text: String, type: BlockContentType) {
        self.init(text: [text], type: type)
    }
}

extension BeginingOfTextMarkdown {
    @MainActor
    static let all: [BeginingOfTextMarkdown] = [
        BeginingOfTextMarkdown(text: "# ", type: .text(.header)),
        BeginingOfTextMarkdown(text: "## ", type: .text(.header2)),
        BeginingOfTextMarkdown(text: "### ", type: .text(.header3)),
        BeginingOfTextMarkdown(text: ["\" ", "\' ", "“ ", "‘ ", "« "], type: .text(.quote)),
        BeginingOfTextMarkdown(text: ["* ", "- ", "+ "], type: .text(.bulleted)),
        BeginingOfTextMarkdown(text: "[] ", type: .text(.checkbox)),
        BeginingOfTextMarkdown(text: "1. ", type: .text(.numbered)),
        BeginingOfTextMarkdown(text: "> ", type: .text(.toggle)),
        BeginingOfTextMarkdown(text: ["``` ", "““ ", "‘‘‘ "], type: .text(.code)),
        BeginingOfTextMarkdown(text: ["--- ", "—- "], type: .divider(.line)),
    ]
}
