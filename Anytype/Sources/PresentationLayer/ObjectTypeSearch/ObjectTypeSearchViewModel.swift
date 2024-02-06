import SwiftUI
import Services


@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    
    private let showLists: Bool
    private let highlightlDefaultObjectType: Bool
    
    private let interactor: ObjectTypeSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    
    private let onSelect: (_ type: ObjectType) -> Void
    
    nonisolated init(
        showLists: Bool,
        highlightlDefaultObjectType: Bool,
        interactor: ObjectTypeSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.showLists = showLists
        self.highlightlDefaultObjectType = highlightlDefaultObjectType
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        Task {
            let listTypes = showLists ? try await interactor.searchListTypes(text: text) : []
            let objectTypes = try await interactor.searchObjectTypes(text: text)
            let libraryTypes = text.isNotEmpty ? try await interactor.searchLibraryTypes(text: text) : []
            let defaultObjectType = try interactor.defaultObjectType()
            
            let sectionData: [SectionData] = Array.builder {
                if listTypes.isNotEmpty {
                    SectionData(
                        section: .lists,
                        types: buildTypeData(types: listTypes, defaultObjectType: defaultObjectType)
                    )
                }
                if objectTypes.isNotEmpty {
                    SectionData(
                        section: .objects,
                        types: buildTypeData(types: objectTypes, defaultObjectType: defaultObjectType)
                    )
                }
                
                if libraryTypes.isNotEmpty {
                    SectionData(
                        section: .library,
                        types: buildTypeData(types: libraryTypes, defaultObjectType: defaultObjectType)
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
    private func buildTypeData(types: [ObjectType], defaultObjectType: ObjectType) -> [ObjectTypeData] {
        return types.map { type in
            ObjectTypeData(
                type: type,
                isHighlighted: highlightlDefaultObjectType && defaultObjectType.id == type.id
            )
        }
    }
}
