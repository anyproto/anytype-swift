import Foundation
import Combine

protocol DashboardServiceProtocol {
    func openDashboard(homeBlockId: String) -> ResponseEvent?
    func createNewPage() -> CreatePageResponse?
}
