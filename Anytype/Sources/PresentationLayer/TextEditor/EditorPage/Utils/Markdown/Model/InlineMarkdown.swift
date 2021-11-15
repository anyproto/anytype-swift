import BlocksModels

struct InlineMarkdown {
    let text: [String]
    let markup: MarkupType
}

extension InlineMarkdown {
    init(text: String, markup: MarkupType) {
        self.init(text: [text], markup: markup)
    }
}

extension InlineMarkdown {
    static let all: [InlineMarkdown] = [        
        InlineMarkdown(text: ["`", "‘"], markup: .keyboard),
        InlineMarkdown(text: ["_", "*"], markup: .italic),
        InlineMarkdown(text: ["__", "**"], markup: .bold),
        InlineMarkdown(text: "~~", markup: .strikethrough),
    ]
}
