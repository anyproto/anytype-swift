import BlocksModels

extension OurEvent {
    struct Focus {
        var blockId: String
        var position: BlockFocusPosition?
    }
    
    struct Text {
        var blockId: String
        var attributedString: NSAttributedString?
    }
    
    struct TextMerge {
        var blockId: String
    }

    struct Toggled {
        var blockId: String
    }
}

enum OurEvent {
    case setFocus(Focus)
    case setText(Text)
    case setTextMerge(TextMerge)
    case setToggled(Toggled)
}
