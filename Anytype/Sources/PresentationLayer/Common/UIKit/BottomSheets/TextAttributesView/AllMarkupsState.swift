import UIKit
import BlocksModels

struct AllMarkupsState {
    let bold: MarkupState
    let italic: MarkupState
    let strikethrough: MarkupState
    let codeStyle: MarkupState
    let alignment: [LayoutAlignment: MarkupState]
    let url: URL?
}
