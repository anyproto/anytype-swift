import Foundation
import SwiftUI
import AnytypeCore

struct EmojiIconView: View {
    
    let emoji: Emoji
    
    var body: some View {
        ImageCharIconView(text: emoji.value)
            .objectIconBackgroundColorModifier()
            .objectIconCornerRadius()
    }
}
