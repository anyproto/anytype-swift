import Foundation
import SwiftUI

extension View {
    func customBackSwipe( _ actionEnded: @escaping () -> Void) -> some View {
        simultaneousGesture(
            DragGesture()
                .onEnded { value in
                    if value.startLocation.x < 50, value.translation.width > 50 {
                        actionEnded()
                    }
                }
        )
    }
}
