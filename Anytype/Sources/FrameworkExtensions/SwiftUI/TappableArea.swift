import Foundation
import SwiftUI

extension View {
    
    func increaseTapGesture(_ edges: EdgeInsets, _ action: @escaping () -> Void) -> some View {
        overlay(
            Color.clear.padding(EdgeInsets(top: -edges.top, leading: -edges.leading, bottom: -edges.bottom, trailing: -edges.trailing))
                .fixTappableArea()
                .onTapGesture(perform: action)
        )
    }
    
    // Enable taps for empty view and spaces
    func fixTappableArea() -> some View {
        contentShape(Rectangle())
    }
}
