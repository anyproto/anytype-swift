import SwiftUI
import Services
import AnytypeCore


@MainActor
final class NewSettingsViewModel: ObservableObject {
    init() { }
    
    func setupSubscriptions() async {
        async let subscription: () = subscribe()
        
        (_) = await (subscription)
    }
    
    // MARK: - Private
    private func subscribe() async {
        
    }
}
