import Foundation
import Combine

protocol DashboardServiceProtocol {
    func createNewPage() -> CreatePageResponse?
}
