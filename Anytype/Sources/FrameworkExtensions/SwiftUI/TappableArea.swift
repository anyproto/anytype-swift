import Foundation
import SwiftUI

struct IncreaseTapGestureV2Modifier: ViewModifier {
    let insets: EdgeInsets
    let onTap: () -> Void
  
    func body(content: Content) -> some View {
        content
            .padding(insets)
            .fixTappableArea()
            .onTapGesture {
                onTap()
            }
            .padding(insets.inverted)
    }
}

extension View {
    
    func increaseTapGesture(_ edges: EdgeInsets, _ action: @escaping () -> Void) -> some View {
        overlay(
            Color.clear.padding(edges.inverted)
                .fixTappableArea()
                .onTapGesture(perform: action)
        )
    }
    
    func increaseTapGestureV2(_ insets: EdgeInsets = EdgeInsets(side: 30), _ action: @escaping () -> Void) -> some View {
        modifier(IncreaseTapGestureV2Modifier(insets: insets, onTap: action))
    }
    
    // Enable taps for empty view and spaces
    func fixTappableArea() -> some View {
        contentShape(Rectangle())
    }
}

extension EdgeInsets {
    var inverted: EdgeInsets {
        EdgeInsets(top: -top, leading: -leading, bottom: -bottom, trailing: -trailing)
    }
}
