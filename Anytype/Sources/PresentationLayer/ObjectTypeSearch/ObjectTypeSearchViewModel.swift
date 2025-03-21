import SwiftUI
import Services
import AnytypeCore

enum TypeSelectionResult {
    case objectType(type: ObjectType)
    case createFromPasteboard
}

@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    @Published var searchText = ""
    @Published var showPasteButton = false
    @Published var newTypeInfo: ObjectTypeInfo?
    @Published var toastData: ToastBarData = .empty
    @Published var participantCanEdit = false
    
    let settings: ObjectTypeSearchViewSettings
    private let spaceId: String
    
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    @Injected(\.accountParticipantsStorage)
    private var accountParticipantStorage: any AccountParticipantsStorageProtocol
    
    private let onSelect: (TypeSelectionResult) -> Void
    private var searchTask: Task<(), any Error>?
    
    init(
        spaceId: String,
        settings: ObjectTypeSearchViewSettings,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) {
        self.settings = settings
        self.spaceId = spaceId
        self.onSelect = onSelect
    }
    
    
    func onAppear() {
        AnytypeAnalytics.instance().logScreenObjectTypeSearch()
        
        search(text: searchText)
        updatePasteButton()
    }
    
    func subscribeOnParticipant() async {
        for await participant in accountParticipantStorage.participantPublisher(spaceId: spaceId).values {
            participantCanEdit = participant.canEdit
        }
    }
    
    func handlePasteboard() async {
        for await _ in pasteboardHelper.pasteboardChangePublisher().values {
            updatePasteButton()
        }
    }
    
    func updatePasteButton() {
        withAnimation {
            showPasteButton = settings.allowPaste && pasteboardHelper.hasSlots
        }
    }
    
    func search(text: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            let pinnedTypes = settings.showPins ? try await typesService.searchPinnedTypes(text: text, spaceId: spaceId) : []
            let listTypes = settings.showLists ? try await typesService.searchListTypes(
                text: searchText, includePins: !settings.showPins, spaceId: spaceId
            ) : []
            let objectTypes = try await typesService.searchObjectTypes(
                text: searchText,
                includePins: !settings.showPins,
                includeLists: false,
                includeBookmarks: true,
                includeFiles: settings.showFiles,
                includeChat: settings.showChat,
                includeTemplates: settings.showTemplates,
                incudeNotForCreation: settings.incudeNotForCreation,
                spaceId: spaceId
            ).map { ObjectType(details: $0) }
            let libraryTypes = text.isNotEmpty ? try await typesService.searchLibraryObjectTypes(
                text: text, includeInstalledTypes: false, spaceId: spaceId
            ).map { ObjectType(details: $0) } : []
            let defaultType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
            
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
            
            try Task.checkCancellation()
            
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
        AnytypeAnalytics.instance().logTypeSearchResult()
        
        Task {
            if section == .library {
                let newTypeDetails = try await workspaceService.installObject(spaceId: spaceId, objectId: type.id)
                let newType = ObjectType(details: newTypeDetails)
                
                toastData = ToastBarData(text: Loc.ObjectType.addedToLibrary(type.displayName), showSnackBar: true)
                
                onSelect(.objectType(type: newType))
            } else {
                onSelect(.objectType(type: type))
            }
        }
    }
    
    func createObjectFromClipboard() {
        Task {
            guard pasteboardHelper.hasSlots else {
                anytypeAssertionFailure("Trying to paste with empty clipboard")
                return
            }
            
            if !pasteboardHelper.isPasteboardEmpty { // No permission
                onSelect(.createFromPasteboard)
            }
        }
        
    }
    
    func createType(name: String) {
        if FeatureFlags.pluralNames {
            newTypeInfo = ObjectTypeInfo(singularName: name, pluralName: name, icon: nil, color: nil)
        } else {
            onCreateTypeSubmit(info: ObjectTypeInfo(singularName: name, pluralName: name, icon: nil, color: nil))
        }
    }

    func onCreateTypeSubmit(info: ObjectTypeInfo) {
        Task {
            let type = try await typesService.createType(name: info.singularName, pluralName: info.pluralName, icon: info.icon, color: info.color, spaceId: spaceId)
            onSelect(.objectType(type: type))
        }
    }
    
    func deleteType(_ type: ObjectType) {
        Task {
            try await typesService.deleteType(typeId: type.id, spaceId: spaceId)
            search(text: searchText)
        }
    }
    
    func setDefaultType(_ type: ObjectType) {
        objectTypeProvider.setDefaultObjectType(type: type, spaceId: spaceId, route: .navigation)
        search(text: searchText)
    }
    
    func addPinedType(_ type: ObjectType) {
        do {
            try typesService.addPinedType(type, spaceId: spaceId)
            AnytypeAnalytics.instance().logPinObjectType(analyticsType: type.analyticsType)
            search(text: searchText)
        } catch { }
    }
    
    func removePinedType(_ type: ObjectType) {
        do {
            try typesService.removePinedType(typeId: type.id, spaceId: spaceId)
            AnytypeAnalytics.instance().logUnpinObjectType(analyticsType: type.analyticsType)
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
