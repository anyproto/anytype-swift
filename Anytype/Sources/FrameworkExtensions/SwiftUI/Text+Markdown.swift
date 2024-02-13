import Foundation
import SwiftUI

extension Text {
    // Disable localization and enable markdown
    init(markdown text: String) {
        let attrString = (try? AttributedString(markdown: text)) ?? AttributedString(text)
        self = Text(attrString)
    }
}
