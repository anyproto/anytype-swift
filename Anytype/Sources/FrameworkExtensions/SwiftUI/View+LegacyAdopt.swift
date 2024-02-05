import Foundation
import SwiftUI

/// Adopt for ios 15

@available(iOS, deprecated: 16)
extension View {
    func hideScrollIndicatorLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollIndicators(.never)
        } else {
            return self
        }
    }
    
    func hideKeyboardOnScrollLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollDismissesKeyboard(.immediately)
        } else {
            return self
        }
    }
    
    func presentationBackgroundLegacy<S>(_ style: S) -> some View where S : ShapeStyle {
        if #available(iOS 16.4, *) {
            return self.presentationBackground(style)
       } else {
            return self
       }
    }
    
    func presentationCornerRadiusLegacy(_ radius: CGFloat?) -> some View {
        if #available(iOS 16.4, *) {
            return self.presentationCornerRadius(radius)
        } else {
            return self
        }
    }

    func presentationDetentsHeightAndLargeLegacy(height: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents([.height(height), .large])
        } else {
            return self
        }
    }
    
    func presentationDragIndicatorHiddenLegacy() -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDragIndicator(.hidden)
        } else {
            return self
        }
    }
    
    func bounceBehaviorBasedOnSize() -> some View {
        if #available(iOS 16.4, *) {
            return self.scrollBounceBehavior(.basedOnSize)
        } else {
            return self
        }
    }
    
    func fixMenuOrder() -> some View {
        if #available(iOS 16.0, *) {
            return self.menuOrder(.fixed)
        } else {
            return self
        }
    }
}
