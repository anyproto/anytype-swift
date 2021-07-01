import Foundation
import Combine

protocol DashboardServiceProtocol {
    func openDashboard(completion: @escaping (ServiceSuccess) -> ())
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceSuccess, Error>    
}
