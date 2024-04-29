import Foundation
import Services
import SwiftUI
import AnytypeCore


enum TypeSelectionResult {
    case objectType(type: ObjectType)
    case createFromPasteboard
}

protocol ObjectTypeSearchModuleAssemblyProtocol: AnyObject {
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
    func makeDefaultTypeSearch(
        title: String,
        spaceId: String,
        showPins: Bool,
        showLists: Bool,
        showFiles: Bool,
        incudeNotForCreation: Bool,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) -> AnyView {
        let settings = ObjectTypeSearchViewSettings(
            showPins: showPins,
            showLists: showLists,
            showFiles: showFiles,
            incudeNotForCreation: incudeNotForCreation,
            allowPaste: false
        )
        
        return ObjectTypeSearchView(
            title: title,
            spaceId: spaceId,
            settings: settings,
            onSelect: { result in
                switch result {
                case .objectType(let type):
                    onSelect(type)
                case .createFromPasteboard:
                    anytypeAssertionFailure("Unsupported action createFromPasteboard")
                }
            }
        ).eraseToAnyView()
    }
}
