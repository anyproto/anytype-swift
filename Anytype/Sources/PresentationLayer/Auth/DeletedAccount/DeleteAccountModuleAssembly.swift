import Foundation
import SwiftUI

protocol DeleteAccountModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(deadline: Date) -> AnyView
}

final class DeleteAccountModuleAssembly: DeleteAccountModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - DeleteAccountModuleAssemblyProtocol
    
    @MainActor
    func make(deadline: Date) -> AnyView {
        return DeletedAccountView(
            viewModel: DeletedAccountViewModel(deadline: deadline, applicationStateService: self.serviceLocator.applicationStateService())
        ).eraseToAnyView()
    }
    
}
