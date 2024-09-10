import Foundation
import Combine
import Services

@MainActor
final class AllContentWidgetViewModel: ObservableObject {
    
    private let onWidgetTap: () -> Void
    
    init(onWidgetTap: @escaping () -> Void) {
        self.onWidgetTap = onWidgetTap
    }
    
    func onTapWidget() {
        onWidgetTap()
    }
}
