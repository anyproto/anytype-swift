import Services

struct InlineMarkdown {
    
    enum Pattern {
        case same(_ text: String)
        case different(_ start: String, _ end: String)
    }
    
    let text: [Pattern]
    let markup: MarkupType
}

extension InlineMarkdown.Pattern: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .same(value)
    }
}

extension InlineMarkdown.Pattern {
    var start: String {
        switch self {
        case let .same(text):
            return text
        case let .different(start, _):
            return start
        }
    }
    
    var end: String {
        switch self {
        case let .same(text):
            return text
        case let .different(_, end):
            return end
        }
    }
    
    var count: Int {
        return start.count + end.count
    }
}

extension InlineMarkdown {
    static let all: [InlineMarkdown] = [
        
        InlineMarkdown(text: ["`"], markup: .keyboard),
        InlineMarkdown(text: ["_", "*"], markup: .italic),
        InlineMarkdown(text: ["__", "**"], markup: .bold),
        InlineMarkdown(text: ["~~"], markup: .strikethrough),
    ]
}
