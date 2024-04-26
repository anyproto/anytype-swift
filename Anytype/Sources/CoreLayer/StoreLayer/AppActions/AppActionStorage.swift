import Combine
import SwiftUI

final class AppActionStorage: ObservableObject {
    static var shared = AppActionStorage()
    
    @Published var action: AppAction?
    
    private init() { }
}
