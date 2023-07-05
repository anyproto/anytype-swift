import Foundation
import SwiftUI

extension View {
    func customBackSwipe( _ actionEnded: @escaping () -> Void) -> some View {
        highPriorityGesture(
            DragGesture()
                .onEnded { value in
                    if value.startLocation.x < 50, value.translation.width > 100 {
                        actionEnded()
                    }
                }
        )
    }
}
