import Foundation
import SwiftUI

struct ObjectIconCornerRadiusBuilder {
    static func calculateObjectIconCornerRadius(size: CGSize) -> CGFloat {
        guard size.width > 0 else { return 0 }
        
        if size.width <= 20 { return 2 }
        if size.width <= 32 { return 5 }
        if size.width <= 40 { return 6 }
        if size.width <= 48 { return 8 }
        if size.width <= 56 { return 10 }
        if size.width <= 64 { return 12 }
        if size.width <= 80 { return 16 }
        if size.width <= 96 { return 20 }
        
        return 24
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

