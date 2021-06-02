import Foundation
import Combine
import BlocksModels
import ProtobufMessages

class DashboardService: DashboardServiceProtocol {
    private let middlewareConfigurationService = MiddlewareConfigurationService()
    private let blocksActionsService = BlockActionsServiceSingle()
    private let objectsService = ObjectActionsService()
    
    private var dashboardId: String = ""
        
    func openDashboard() -> AnyPublisher<ServiceSuccess, Error> {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [weak self] configuration -> AnyPublisher<ServiceSuccess, Error> in
            guard let self = self else {
                return .empty()
            }
            
            return self.blocksActionsService.open(
                contextID: configuration.homeBlockID, blockID: configuration.homeBlockID
            )
        }.eraseToAnyPublisher()
    }
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceSuccess, Error> {
        objectsService.createPage(
            contextID: contextId,
            targetID: "",
            details: [.name: DetailsEntry(value: "")],
            position: .bottom,
            templateID: ""
        )
    }
    
    private func save(configuration: MiddlewareConfiguration) -> MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
}
