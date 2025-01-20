import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder()
                .setZeroOpacity(!shouldShow)
                .animation(nil, value: shouldShow)
            self
        }
    }
}
