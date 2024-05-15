import Foundation
import SwiftUI

private struct SpaceIconCornerRadiusModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        GeometryReader { reader in
            content
                .cornerRadius(cornerRadius(size: reader.size), style: .continuous)
        }
    }
    
    private func cornerRadius(size: CGSize) -> CGFloat {
        guard size.width > 0 else { return 0 }
        return max(size.width / 12, 3)
    }
}

extension View {
    func spaceIconCornerRadius() -> some View {
        modifier(SpaceIconCornerRadiusModifier())
    }
}

