import Foundation
import SwiftUI

@MainActor
protocol SpaceMembersModuleAssemblyProtocol: AnyObject {
    func make() -> AnyView
}

@MainActor
final class SpaceMembersModuleAssembly: SpaceMembersModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    func make() -> AnyView {
        return SpaceMembersView(
            model: SpaceMembersViewModel(
                participantSubscriptionService: self.serviceLocator.participantSubscriptionBySpaceService()
            )
        ).eraseToAnyView()
    }
}
