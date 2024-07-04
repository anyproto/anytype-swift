import Foundation
import SwiftUI

@MainActor
final class HomeUpdateSubmoduleViewModel: ObservableObject {
    
    @Injected(\.appVersionService)
    private var appVersionService: any AppVersionServiceProtocol
    
    @Published var showUpdateAlert: Bool = false
    @Published var openUrl: URL?
    
    init() {
        Task {
            do {
                let result = try await appVersionService.newVersionIsAvailable()
                showUpdateAlert = result
            } catch {
                showUpdateAlert = false
            }
        }
    }
    
    func onTapUpdate() {
        openUrl = AppLinks.storeLink
    }
}
