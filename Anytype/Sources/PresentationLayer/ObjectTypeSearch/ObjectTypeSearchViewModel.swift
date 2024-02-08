import SwiftUI
import Services


@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    @Published var searchText = ""
    
    let showPins: Bool
    private let showLists: Bool
    
    private let interactor: ObjectTypeSearchInteractor
    private let toastPresenter: ToastPresenterProtocol
    
    private let onSelect: (_ type: ObjectType) -> Void
    private var searchTask: Task<(), any Error>?
    
    nonisolated init(
        showPins: Bool,
        showLists: Bool,
        interactor: ObjectTypeSearchInteractor,
        toastPresenter: ToastPresenterProtocol,
        onSelect: @escaping (_ type: ObjectType) -> Void
    ) {
        self.showPins = showPins
        self.showLists = showLists
        self.interactor = interactor
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
    }
    
    func search(text: String) {
        searchTask?.cancel()
        
        searchTask = Task { @MainActor in
            let pinnedTypes = showPins ? try await interactor.searchPinnedTypes(text: text) : []
            let listTypes = showLists ? try await interactor.searchListTypes(text: text, includePins: !showPins) : []
            let objectTypes = try await interactor.searchObjectTypes(text: text, includePins: !showPins)
            let libraryTypes = text.isNotEmpty ? try await interactor.searchLibraryTypes(text: text) : []
            let defaultType = try interactor.defaultObjectType()
            
            let sectionData: [SectionData] = Array.builder {
                if pinnedTypes.isNotEmpty {
                    SectionData(
                        section: .pins,
                        types: buildTypeData(types: pinnedTypes, defaultType: defaultType)
                    )
                }
                
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
            
            withAnimation(.easeOut(duration: 0.2)) {
                if sectionData.isNotEmpty {
                    state = .searchResults(sectionData)
                } else {
                    state = .emptyScreen
                }
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
    
    func deleteType(_ type: ObjectType) {
        Task {
            try await interactor.deleteType(type)
            search(text: searchText)
        }
    }
    
    func setDefaultType(_ type: ObjectType) {
        interactor.setDefaultObjectType(type)
        search(text: searchText)
    }
    
    func addPinedType(_ type: ObjectType) {
        do {
            try interactor.addPinedType(type)
            search(text: searchText)
        } catch { }
    }
    
    func removePinedType(_ type: ObjectType) {
        do {
            try interactor.removePinedType(type)
            search(text: searchText)
        } catch { }
    }
    
    // MARK: - Private
    private func buildTypeData(types: [ObjectType], defaultType: ObjectType) -> [ObjectTypeData] {
        return types.map { type in
            ObjectTypeData(
                type: type,
                isDefault: defaultType.id == type.id
            )
        }
    }
}
