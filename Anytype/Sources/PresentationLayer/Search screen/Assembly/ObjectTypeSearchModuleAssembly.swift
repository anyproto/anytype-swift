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
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView {
        if FeatureFlags.newTypePicker {
            return ObjectTypeSearchView(
                title: title,
                viewModel: ObjectTypeSearchViewModel(
                    showPins: showPins,
                    showLists: showLists,
                    showFiles: showFiles,
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
        } else {
            let interactor = Legacy_ObjectTypeSearchInteractor(
                spaceId: spaceId,
                typesService: serviceLocator.typesService(),
                workspaceService: serviceLocator.workspaceService(),
                objectTypeProvider: serviceLocator.objectTypeProvider(),
                showBookmark: true,
                showSetAndCollection: true, 
                showFiles: showFiles
            )
            
            let internalViewModel = Legacy_ObjectTypeSearchViewModel(
                interactor: interactor,
                toastPresenter: uiHelpersDI.toastPresenter(),
                selectedObjectId: nil,
                hideMarketplace: true,
                showDescription: false,
                onSelect: onSelect
            )
            let viewModel = NewSearchViewModel(
                title: Loc.createNewObject,
                searchPlaceholder: Loc.ObjectType.search,
                focusedBar: false,
                style: .default,
                itemCreationMode: .unavailable,
                internalViewModel: internalViewModel
            )
            
            return NewSearchView(viewModel: viewModel).eraseToAnyView()
        }
    }
}
