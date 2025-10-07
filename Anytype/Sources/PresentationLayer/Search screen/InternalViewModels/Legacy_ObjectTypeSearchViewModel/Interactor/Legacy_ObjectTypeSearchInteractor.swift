import Foundation
import Services
import AnytypeCore

@MainActor
final class Legacy_ObjectTypeSearchInteractor {
    
    private let spaceId: String
    
    @Injected(\.typesService)
    private var typesService: any TypesServiceProtocol
    @Injected(\.workspaceService)
    private var workspaceService: any WorkspaceServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    
    private let showBookmark: Bool
    private let showSetAndCollection: Bool
    private let showFiles: Bool
    
    init(
        spaceId: String,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        showFiles: Bool
    ) {
        self.spaceId = spaceId
        self.showBookmark = showBookmark
        self.showSetAndCollection = showSetAndCollection
        self.showFiles = showFiles
    }
    
}

extension Legacy_ObjectTypeSearchInteractor {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await typesService.searchObjectTypes(
            text: text, 
            includePins: true,
            includeLists: showSetAndCollection,
            includeBookmarks: showBookmark,
            includeFiles: showFiles,
            includeChat: false,
            includeTemplates: true,
            incudeNotForCreation: true,
            spaceId: spaceId
        )
    }
    
    func searchInLibrary(text: String) async throws -> [ObjectDetails] {
        return try await typesService.searchLibraryObjectTypes(text: text, includeInstalledTypes: false, spaceId: spaceId)
    }
    
    func installType(objectId: String) async throws -> ObjectDetails {
        try await workspaceService.installObject(spaceId: spaceId, objectId: objectId)
    }
}

