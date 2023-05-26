import Foundation
import SwiftUI

// Alternative for readableContentGuide in UIKit

struct ReadableContentGuide: ViewModifier {
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if UIDevice.isPad {
            HStack(spacing: 0) {
                Spacer()
                content
                    .frame(maxWidth: 670)
                Spacer()
            }
        } else {
            content
        }
    }
}

extension View {
    func fitIPadToReadableContentGuide() -> some View {
        modifier(ReadableContentGuide())
    }
}
