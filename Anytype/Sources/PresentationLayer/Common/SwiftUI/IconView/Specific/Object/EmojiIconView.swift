import Foundation
import SwiftUI
import AnytypeCore

struct EmojiIconView: View {

    let emoji: Emoji
    let circular: Bool

    var body: some View {
        ImageCharIconView(text: emoji.value)
            .objectIconBackgroundColorModifier()
            .if(circular, if: {
                $0.circleOverCornerRadius()
            }, else: {
                $0.objectIconCornerRadius()
            })
    }
}
