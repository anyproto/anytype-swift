import Foundation
import SwiftUI

protocol StatusRelationListModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(title: String) -> AnyView
}

final class StatusRelationListModuleAssembly: StatusRelationListModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - StatusRelationListModuleAssemblyProtocol
    
    @MainActor
    func make(title: String) -> AnyView {
        StatusRelationListView(
            viewModel: StatusRelationListViewModel(
                title: title
            )
        )
        .eraseToAnyView()
    }
}
