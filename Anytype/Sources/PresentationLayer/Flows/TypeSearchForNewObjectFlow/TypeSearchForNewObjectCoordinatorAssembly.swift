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
        let model = TypeSearchForNewObjectCoordinatorViewModel(
            objectTypeSearchAssembly: modulesDI.objectTypeSearch(),
            pasteboardBlockService: serviceLocator.pasteboardBlockService(),
            objectActionsService: serviceLocator.objectActionsService(),
            blockService: serviceLocator.blockService(),
            bookmarkService: serviceLocator.bookmarkService(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            typeProvider: serviceLocator.objectTypeProvider(),
            openObject: openObject
        )
        
        return TypeSearchForNewObjectCoordinatorView(
            model: model
        ).eraseToAnyView()
    }
}
