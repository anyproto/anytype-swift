import Foundation
import UIKit

struct SecureAlertData: Identifiable {
    let id = UUID()
    let completion: (_ proceed: Bool) -> Void
}

@MainActor
final class SecureAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    
    private let data: SecureAlertData
    
    init(data: SecureAlertData) {
        self.data = data
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        data.completion(false)
        dismiss.toggle()
    }
    
    func proceed() {
        data.completion(true)
        dismiss.toggle()
    }
}
