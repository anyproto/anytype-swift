import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.BackgroundNew.primary).cornerRadius(10)
    }
}
