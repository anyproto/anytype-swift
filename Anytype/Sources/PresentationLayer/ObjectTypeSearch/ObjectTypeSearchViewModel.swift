import SwiftUI
import Services


@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    
    private let onSelect: (_ type: ObjectType) -> Void
    
    private let interactor: ObjectTypeSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    
    nonisolated init(
        onSelect: @escaping (_ type: ObjectType) -> Void,
        interactor: ObjectTypeSearchInteractor,
        toastPresenter: ToastPresenterProtocol
    ) {
        self.onSelect = onSelect
        self.interactor = interactor
        self.toastPresenter = toastPresenter
    }
    
    func search(text: String) {
        Task {
            var sectionData: [SectionData] = []
            
            let listTypes = await interactor.searchListTypes(text: text)
            if listTypes.isNotEmpty {
                sectionData.append(
                    SectionData(section: .lists, types: listTypes)
                )
            }
            
            let objectTypes = await interactor.searchObjectTypes(text: text)
            if objectTypes.isNotEmpty {
                sectionData.append(
                    SectionData(section: .objects, types: objectTypes)
                )
            }
            
            if text.isNotEmpty {
                let libraryTypes = await interactor.searchLibraryTypes(text: text)
                if libraryTypes.isNotEmpty {
                    sectionData.append(
                        SectionData(section: .library, types: libraryTypes)
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
            do {
                if section == .library {
                    try await interactor.installType(objectId: type.id)
                    toastPresenter.show(message: Loc.ObjectType.addedToLibrary(type.name))
                }
                
                onSelect(type)
            }
        }
    }
}
