extension BlockContent {
    public var identifier: String {
        switch self {
        case .smartblock(_): return ".smartblock"
        case let .text(value): return ".text" + value.textIdentifier
        case .file(_): return ".file"
        case .divider(_): return ".divider"
        case .bookmark(_): return ".bookmark"
        case .link(_): return ".link"
        case .layout(_): return ".layout"
        }
    }
}

extension BlockText {
    public var textIdentifier: String {
        switch self.contentType {
        case .description: return "description"
        case .title: return ".title"
        case .text: return ".text"
        case .header: return ".header"
        case .header2: return ".header2"
        case .header3: return ".header3"
        case .header4: return ".header4"
        case .quote: return ".quote"
        case .checkbox: return ".checkbox"
        case .bulleted: return ".bulleted"
        case .numbered: return ".numbered"
        case .toggle: return ".toggle"
        case .code: return ".code"
        }
    }
}
