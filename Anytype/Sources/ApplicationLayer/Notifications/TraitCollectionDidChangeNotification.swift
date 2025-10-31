import Foundation
import SwiftUI

extension NSNotification.Name {
    static let traitCollectionDidChangeNotification = NSNotification.Name("anytype.traitCollectionDidChange")
}

private struct TraitCollectionNotifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onChange(of: colorScheme) {
                NotificationCenter.default.post(
                    name: .traitCollectionDidChangeNotification,
                    object: nil
                )
            }
    }
}

extension View {
    func setupTraitCollectionNotifier() -> some View {
        modifier(TraitCollectionNotifier())
    }
}
