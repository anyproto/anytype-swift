import SwiftUI

struct LogoOverlay: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                Image.logo.padding(.leading, 20).padding(.top, 30),
                alignment: .topLeading
            )
    }
}
