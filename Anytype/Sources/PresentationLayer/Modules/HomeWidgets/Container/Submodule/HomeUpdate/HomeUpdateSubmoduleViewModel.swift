import Foundation
import SwiftUI

@MainActor
@Observable
final class HomeUpdateSubmoduleViewModel {

    @ObservationIgnored
    @Injected(\.appVersionUpdateService)
    private var appVersionUpdateService: any AppVersionUpdateServiceProtocol

    var showUpdateAlert: Bool = false
    var openUrl: URL?
    
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
