import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.Background.primary).clipShape(.rect(cornerRadius: 10))
    }
}
