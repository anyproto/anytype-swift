import SwiftUI

@MainActor
final class JoinFlowViewModel: ObservableObject {
    
    @Published var currentIndex: Int = 0
    let colors = [Color.Auth.body, Color.Auth.caption, Color.Text.secondary]
    
}
