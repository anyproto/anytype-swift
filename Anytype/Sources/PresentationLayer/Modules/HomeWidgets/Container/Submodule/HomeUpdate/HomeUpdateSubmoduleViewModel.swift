import Foundation
import SwiftUI

@MainActor
final class HomeUpdateSubmoduleViewModel: ObservableObject {
    
    @Injected(\.appVersionUpdateService)
    private var appVersionUpdateService: any AppVersionUpdateServiceProtocol
    
    @Published var showUpdateAlert: Bool = false
    @Published var openUrl: URL?
    
    init() {
        #if RELEASE_ANYTYPE
        Task {
            do {
                let result = try await appVersionUpdateService.newVersionIsAvailable()
                showUpdateAlert = result
            } catch {
                showUpdateAlert = false
            }
        }
        #endif
    }
    
    func onTapUpdate() {
        openUrl = AppLinks.storeLink
    }
}
