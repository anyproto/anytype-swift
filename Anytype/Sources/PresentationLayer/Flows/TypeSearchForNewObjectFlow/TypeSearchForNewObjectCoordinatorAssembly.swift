import SwiftUI
import AnytypeCore
import Services


@MainActor
protocol TypeSearchForNewObjectCoordinatorAssemblyProtocol {
    func make(openObject: @escaping (ObjectDetails)->()) -> AnyView
}

final class TypeSearchForNewObjectCoordinatorAssembly: TypeSearchForNewObjectCoordinatorAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    private let modulesDI: ModulesDIProtocol
    
    nonisolated init(
        serviceLocator: ServiceLocator,
        modulesDI: ModulesDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.modulesDI = modulesDI
    }
    
    func make(openObject: @escaping (ObjectDetails)->()) -> AnyView {
        return TypeSearchForNewObjectCoordinatorView(
            model: TypeSearchForNewObjectCoordinatorViewModel(
                pasteboardBlockService: self.serviceLocator.pasteboardBlockService(),
                objectActionsService: self.serviceLocator.objectActionsService(),
                blockService: self.serviceLocator.blockService(),
                bookmarkService: self.serviceLocator.bookmarkService(),
                activeWorkspaceStorage: self.serviceLocator.activeWorkspaceStorage(),
                typeProvider: self.serviceLocator.objectTypeProvider(),
                openObject: openObject
            )
        ).eraseToAnyView()
    }
}
