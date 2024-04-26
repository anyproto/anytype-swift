import Foundation
import Services
import SwiftUI
import AnytypeCore


enum TypeSelectionResult {
    case objectType(type: ObjectType)
    case createFromPasteboard
}

protocol ObjectTypeSearchModuleAssemblyProtocol: AnyObject {
    func makeTypeSearchForNewObjectCreation(
        title: String,
        spaceId: String,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) -> AnyView
    
    func makeDefaultTypeSearch(
        title: String,
        spaceId: String,
        showPins: Bool,
        showLists: Bool,
        showFiles: Bool,
        incudeNotForCreation: Bool,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView
}

final class ObjectTypeSearchModuleAssembly: ObjectTypeSearchModuleAssemblyProtocol {
    
    private let uiHelpersDI: UIHelpersDIProtocol
    private let serviceLocator: ServiceLocator
    
    init(uiHelpersDI: UIHelpersDIProtocol, serviceLocator: ServiceLocator) {
        self.uiHelpersDI = uiHelpersDI
        self.serviceLocator = serviceLocator
    }
    
    func makeTypeSearchForNewObjectCreation(
        title: String,
        spaceId: String,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) -> AnyView {
        return ObjectTypeSearchView(
            title: title,
            viewModel: ObjectTypeSearchViewModel(
                showPins: true,
                showLists: true,
                showFiles: false,
                incudeNotForCreation: false,
                allowPaste: true,
                spaceId: spaceId,
                workspaceService: self.serviceLocator.workspaceService(),
                typesService: self.serviceLocator.typesService(),
                objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                pasteboardHelper: self.serviceLocator.pasteboardHelper(),
                onSelect: onSelect
            )
        ).eraseToAnyView()
    }
    
    func makeDefaultTypeSearch(
        title: String,
        spaceId: String,
        showPins: Bool,
        showLists: Bool,
        showFiles: Bool,
        incudeNotForCreation: Bool,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView {
        return ObjectTypeSearchView(
            title: title,
            viewModel: ObjectTypeSearchViewModel(
                showPins: showPins,
                showLists: showLists,
                showFiles: showFiles,
                incudeNotForCreation: incudeNotForCreation,
                allowPaste: false,
                spaceId: spaceId,
                workspaceService: self.serviceLocator.workspaceService(),
                typesService: self.serviceLocator.typesService(),
                objectTypeProvider: self.serviceLocator.objectTypeProvider(),
                toastPresenter: self.uiHelpersDI.toastPresenter(),
                pasteboardHelper: self.serviceLocator.pasteboardHelper(),
                onSelect: { result in
                    switch result {
                    case .objectType(let type):
                        onSelect(type)
                    case .createFromPasteboard:
                        anytypeAssertionFailure("Unsupported action createFromPasteboard")
                    }
                }
            )
        ).eraseToAnyView()
    }
}
