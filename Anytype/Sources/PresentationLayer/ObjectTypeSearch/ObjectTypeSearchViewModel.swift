import SwiftUI
import Services


@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    
    private let showLists: Bool
    private let highlightlDefaultType: Bool
    
    private let interactor: ObjectTypeSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    
    private let onSelect: (_ type: ObjectType) -> Void
    
    nonisolated init(
        showLists: Bool,
        highlightlDefaultType: Bool,
        interactor: ObjectTypeSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.showLists = showLists
        self.highlightlDefaultType = highlightlDefaultType
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        Task {
            let listTypes = showLists ? try await interactor.searchListTypes(text: text) : []
            let objectTypes = try await interactor.searchObjectTypes(text: text)
            let libraryTypes = text.isNotEmpty ? try await interactor.searchLibraryTypes(text: text) : []
            let defaultType = try interactor.defaultObjectType()
            
            let sectionData: [SectionData] = Array.builder {
                if listTypes.isNotEmpty {
                    SectionData(
                        section: .lists,
                        types: buildTypeData(types: listTypes, defaultType: defaultType)
                    )
                }
                if objectTypes.isNotEmpty {
                    SectionData(
                        section: .objects,
                        types: buildTypeData(types: objectTypes, defaultType: defaultType)
                    )
                }
                
                if libraryTypes.isNotEmpty {
                    SectionData(
                        section: .library,
                        types: buildTypeData(types: libraryTypes, defaultType: defaultType)
                    )
                }
            }
            
            if sectionData.isNotEmpty {
                state = .searchResults(sectionData)
            } else {
                state = .emptyScreen
            }
        }
    }
    
    func didSelectType(_ type: ObjectType, section: SectionType) {
        Task {
            if section == .library {
                try await interactor.installType(objectId: type.id)
                toastPresenter.show(message: Loc.ObjectType.addedToLibrary(type.name))
            }
            
            onSelect(type)
        }
    }
    
    func createType(name: String) {
        Task {
            let type = try await interactor.createNewType(name: name)
            onSelect(type)
        }
    }
    
    // MARK: - Private
    private func buildTypeData(types: [ObjectType], defaultType: ObjectType) -> [ObjectTypeData] {
        return types.map { type in
            ObjectTypeData(
                type: type,
                isHighlighted: highlightlDefaultType && defaultType.id == type.id
            )
        }
    }
}
