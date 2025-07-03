import Foundation
import UIKit

struct SecureAlertData: Identifiable {
    let id = UUID()
    let completion: (_ proceed: Bool) async throws -> Void
}

@MainActor
final class SecureAlertViewModel: ObservableObject {
    
    @Published var dismiss = false
    @Published var proceedTaskId: String?
    @Published var inProgress = false
    
    private let data: SecureAlertData
    
    init(data: SecureAlertData) {
        self.data = data
    }
    
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        dismiss.toggle()
    }
    
    func proceedTap() {
        proceedTaskId = UUID().uuidString
    }
    
    func proceed() async {
        inProgress = true
        try? await data.completion(true)
        inProgress = false
        dismiss.toggle()
    }
}
