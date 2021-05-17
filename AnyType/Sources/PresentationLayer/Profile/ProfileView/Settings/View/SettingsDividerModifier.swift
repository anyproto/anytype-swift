import SwiftUI

extension SettingsSectionView {
    struct DividerModifier: ViewModifier {
        func body(content: Content) -> some View {
            VStack {
                content
                Divider().foregroundColor(Color.divider)
            }
        }
    }
}
