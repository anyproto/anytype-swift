import SwiftUI

struct DividerModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            content
            Divider().foregroundColor(Color.divider)
        }
    }
}
