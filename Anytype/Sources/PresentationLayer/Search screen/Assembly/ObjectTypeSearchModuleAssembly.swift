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
    
    init(uiHelpersDI: UIHelpersDIProtocol) {
        self.uiHelpersDI = uiHelpersDI
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
                toastPresenter: self.uiHelpersDI.toastPresenter(),
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
                toastPresenter: self.uiHelpersDI.toastPresenter(),
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
