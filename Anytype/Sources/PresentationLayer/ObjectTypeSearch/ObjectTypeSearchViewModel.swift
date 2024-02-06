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
            let isHighlighted: (String) -> Bool = { typeId in
                self.highlightlDefaultObjectType && defaultObjectType.id == typeId
            }
            
            let sectionData: [SectionData] = Array.builder {
                if listTypes.isNotEmpty {
                    SectionData(
                        section: .lists,
                        types: listTypes.map {
                            ObjectTypeData(type: $0, isHighlighted: isHighlighted($0.id))
                        }
                    )
                }
                if objectTypes.isNotEmpty {
                    SectionData(
                        section: .objects,
                        types: objectTypes.map {
                            ObjectTypeData(type: $0, isHighlighted: isHighlighted($0.id))
                        }
                    )
                }
                
                if libraryTypes.isNotEmpty {
                    SectionData(
                        section: .library,
                        types: libraryTypes.map {
                            ObjectTypeData(type: $0, isHighlighted: isHighlighted($0.id))
                        }
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
}
