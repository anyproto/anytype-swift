import Foundation
import Combine

protocol DashboardServiceProtocol {
    func openDashboard() -> ResponseEvent?
    func createNewPage() -> CreatePageResponse?
}
