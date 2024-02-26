import SwiftUI
import AnytypeCore
import Services


enum TypeSearchForNewObjectCoordinatorResult {
    case object(type: ObjectType, pasteContent: Bool)
    case bookmark(url: AnytypeURL)
    case error
}


@MainActor
protocol TypeSearchForNewObjectCoordinatorAssemblyProtocol {
    func make(completion: @escaping (TypeSearchForNewObjectCoordinatorResult)->()) -> AnyView
}

final class TypeSearchForNewObjectCoordinatorAssembly: TypeSearchForNewObjectCoordinatorAssemblyProtocol {
    
    private let objectTypeSearchAssembly: ObjectTypeSearchModuleAssemblyProtocol
    private let pasteboardBlockService: PasteboardBlockServiceProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    private let typeProvider: ObjectTypeProviderProtocol
    
    nonisolated init(
        serviceLocator: ServiceLocator,
        modulesDI: ModulesDIProtocol
    ) {
        self.objectTypeSearchAssembly = modulesDI.objectTypeSearch()
        self.pasteboardBlockService = serviceLocator.pasteboardBlockService()
        self.activeWorkspaceStorage = serviceLocator.activeWorkspaceStorage()
        self.typeProvider = serviceLocator.objectTypeProvider()
    }
    
    func make(completion: @escaping (TypeSearchForNewObjectCoordinatorResult)->()) -> AnyView {
        return objectTypeSearchAssembly.makeTypeSearchForNewObjectCreation(
            title: Loc.createNewObject,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId
        ) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .objectType(let type):
                completion(.object(type: type, pasteContent: false))
            case .createFromPasteboard:
                switch pasteboardBlockService.pasteboardContent {
                case .none:
                    anytypeAssertionFailure("No content in Pasteboard")
                    completion(.error)
                case .url(let url):
                    completion(.bookmark(url: url))
                case .string:
                    fallthrough
                case .otherContent:
                    guard let type = try? typeProvider.defaultObjectType(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) else {
                        completion(.error)
                        return
                    }
                    
                    completion(.object(type: type, pasteContent: true))
                }
            }
        }
    }
}
