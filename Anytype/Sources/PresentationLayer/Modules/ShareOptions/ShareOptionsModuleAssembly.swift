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
                    blockService: self.serviceLocator.blockService(),
                    bookmarkService: self.serviceLocator.bookmarkService(),
                    objectActionsService: self.serviceLocator.objectActionsService(),
                    fileService: self.serviceLocator.fileService(),
                    documentProvider: self.serviceLocator.documentsProvider,
                    pasteboardMiddlewareService: self.serviceLocator.pasteboardMiddlewareService(),
                    objectTpeProvider: self.serviceLocator.objectTypeProvider()
                ),
                activeWorkpaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                output: output
            )
        ).eraseToAnyView()
    }
}
