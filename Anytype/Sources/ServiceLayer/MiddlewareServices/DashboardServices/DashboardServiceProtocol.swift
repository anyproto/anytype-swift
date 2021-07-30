import Foundation
import Combine

protocol DashboardServiceProtocol {
    func openDashboard(completion: @escaping (ResponseEvent) -> ())
    
    func createNewPage(contextId: String) -> AnyPublisher<ResponseEvent, Error>    
}
