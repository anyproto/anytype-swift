import Foundation
import SwiftUI

public extension AttributedString {
    
    mutating func anytypeStyle(_ style: AnytypeFont) {
        let anytypeFont = AnytypeFontBuilder.font(anytypeFont: style)
        self.font = anytypeFont
        self.kern = style.config.kern
        // Line spacing doesn't apply
    }
}
