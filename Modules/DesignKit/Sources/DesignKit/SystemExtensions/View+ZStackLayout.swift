import SwiftUI

public extension View {
    
    @inlinable
    func zStackPosition(_ alignment: Alignment) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}
