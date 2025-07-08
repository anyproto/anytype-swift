import Foundation
import SwiftUI

struct ObjectIconCornerRadiusBuilder {
    static func calculateObjectIconCornerRadius(size: CGSize) -> CGFloat {
        guard size.width > 0 else { return 0 }
        return max(size.width / 8, 3)
    }
}

private struct ObjectIconCornerRadiusModifier: ViewModifier {
    
    @State private var size: CGSize = .zero
    
    func body(content: Content) -> some View {
        content
            .readSize {
                size = $0
            }
            .cornerRadius(ObjectIconCornerRadiusBuilder.calculateObjectIconCornerRadius(size: size), style: .continuous)
    }
}

extension View {
    func objectIconCornerRadius() -> some View {
        modifier(ObjectIconCornerRadiusModifier())
    }
}

