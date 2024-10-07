import Foundation
import SwiftUI

private struct ObjectIconCornerRadiusModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .cornerRadius(cornerRadius(size: reader.size), style: .continuous)
        }
    }
    
    private func cornerRadius(size: CGSize) -> CGFloat {
        guard size.width > 0 else { return 0 }
        return max(size.width / 8, 3)
    }
}

extension View {
    func objectIconCornerRadius() -> some View {
        modifier(ObjectIconCornerRadiusModifier())
    }
}

