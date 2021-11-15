import Combine
import SwiftUI

final class QuickActionsStorage: ObservableObject {
    static var shared = QuickActionsStorage()
    
    @Published var action: QuickAction?
    
    private init() { }
}
