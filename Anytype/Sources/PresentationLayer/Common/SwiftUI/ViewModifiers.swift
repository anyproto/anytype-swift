import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.backgroundPrimary).cornerRadius(10)
    }
}
