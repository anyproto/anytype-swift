import Foundation
import SwiftUI

struct ObjectIconCornerRadiusBuilder {
    static func calculateObjectIconCornerRadius(size: CGSize) -> CGFloat {
        guard size.width > 0 else { return 0 }
        return max(size.width / 8, 3)
    }
}

private struct ObjectIconCornerRadiusModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .cornerRadius(ObjectIconCornerRadiusBuilder.calculateObjectIconCornerRadius(size: reader.size), style: .continuous)
        }
    }
}

extension View {
    func objectIconCornerRadius() -> some View {
        modifier(ObjectIconCornerRadiusModifier())
    }
}

