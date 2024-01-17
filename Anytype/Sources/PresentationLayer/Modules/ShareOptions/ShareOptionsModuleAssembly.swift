import Foundation
import SwiftUI

@MainActor
protocol ShareOptionsModuleAssemblyProtocol: AnyObject {
    func make(output: ShareOptionsModuleOutput?) -> AnyView
}

@MainActor
final class ShareOptionsModuleAssembly: ShareOptionsModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    
    nonisolated init(serviceLocator: ServiceLocator) {
        self.serviceLocator = serviceLocator
    }
    
    // MARK: - ShareOptionsModuleAssemblyProtocol
    
    func make(output: ShareOptionsModuleOutput?) -> AnyView {
        return ShareOptionsView(
            model: ShareOptionsViewModel(
                contentManager: self.serviceLocator.sharedContentManager,
                interactor: ShareOptionsInteractor(
                    listService: self.serviceLocator.blockListService(),
                    bookmarkService: self.serviceLocator.bookmarkService(),
                    objectActionsService: self.serviceLocator.objectActionsService(),
                    blockActionService: self.serviceLocator.blockActionsServiceSingle(),
                    pageRepository: self.serviceLocator.pageRepository(),
                    fileService: self.serviceLocator.fileService()
                ),
                activeWorkpaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                output: output
            )
        ).eraseToAnyView()
    }
}
