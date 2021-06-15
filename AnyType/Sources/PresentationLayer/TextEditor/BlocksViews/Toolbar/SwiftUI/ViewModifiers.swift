import SwiftUI

struct RoundedButtonViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).background(Color.background).cornerRadius(10)
    }
}

struct OuterHorizontalStackViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .top) {
            VStack {
                content
                Spacer(minLength: 10)
            }
        }.padding(16)
    }
}

struct HorizontalStackViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 5) {
            content
        }
    }
}
