import Foundation
import Combine

protocol DashboardServiceProtocol {
    func openDashboard() -> AnyPublisher<ServiceSuccess, Error>
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceSuccess, Error>    
}
