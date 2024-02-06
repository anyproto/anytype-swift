import Foundation
import Services
import SwiftUI
import AnytypeCore

protocol ObjectTypeSearchModuleAssemblyProtocol: AnyObject {
    
    func make(
        title: String,
        spaceId: String,
        showLists: Bool,
        highlightlDefaultType: Bool,
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
    
    func make(
        title: String,
        spaceId: String,
        showLists: Bool,
        highlightlDefaultType: Bool,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView {
        if FeatureFlags.newTypePicker {
            let interactor = ObjectTypeSearchInteractor(
                spaceId: spaceId,
                searchService: serviceLocator.searchService(),
                workspaceService: serviceLocator.workspaceService(),
                typesService: serviceLocator.typesService(),
                objectTypeProvider: serviceLocator.objectTypeProvider()
            )
            
            let model = ObjectTypeSearchViewModel(
                showLists: showLists,
                highlightlDefaultType: highlightlDefaultType,
                interactor: interactor,
                toastPresenter: uiHelpersDI.toastPresenter(),
                onSelect: onSelect
            )
            
            return ObjectTypeSearchView(
                title: title,
                viewModel: model
            ).eraseToAnyView()
        } else {
            let interactor = Legacy_ObjectTypeSearchInteractor(
                spaceId: spaceId,
                searchService: serviceLocator.searchService(),
                workspaceService: serviceLocator.workspaceService(),
                objectTypeProvider: serviceLocator.objectTypeProvider(),
                excludedObjectTypeId: nil,
                showBookmark: true,
                showSetAndCollection: true
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
