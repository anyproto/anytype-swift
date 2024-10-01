import Foundation
import SwiftUI

private struct ObjectIconBackgroundColorModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .if(reader.size.width > 20) {
                    $0.background(Color.Shape.tertiary)
                }
        }
    }
}

extension View {
    func objectIconBackgroundColorModifier() -> some View {
        modifier(ObjectIconBackgroundColorModifier())
    }
}

