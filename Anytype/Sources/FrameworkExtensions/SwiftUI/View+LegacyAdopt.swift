import Foundation
import SwiftUI

/// Adopt for ios 15

@available(iOS, deprecated: 16.4)
extension View {
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

    func bounceBehaviorBasedOnSize() -> some View {
        if #available(iOS 16.4, *) {
            return self.scrollBounceBehavior(.basedOnSize)
        } else {
            return self
        }
    }
    
    func menuActionDisableDismissBehavior() -> some View {
        if #available(iOS 16.4, *) {
            return self.menuActionDismissBehavior(.disabled)
        } else {
            return self
        }
    }
}

@available(iOS, deprecated: 17.0)
extension View {
    @ViewBuilder
    func onChangeIfiOS17<V>(of value: V, initial: Bool = false, _ action: @escaping (_ oldValue: V, _ newValue: V) -> Void) -> some View where V : Equatable {
        if #available(iOS 17.0, *) {
            onChange(of: value, initial: initial, action)
        } else {
            self
        }
    }
}
