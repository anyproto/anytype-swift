import UIKit

struct TextAttributesState {
    var bold: MarkupState
    var italic: MarkupState
    var strikethrough: MarkupState
    var codeStyle: MarkupState
    var alignment: NSTextAlignment = .left
    var url: String = ""
}
