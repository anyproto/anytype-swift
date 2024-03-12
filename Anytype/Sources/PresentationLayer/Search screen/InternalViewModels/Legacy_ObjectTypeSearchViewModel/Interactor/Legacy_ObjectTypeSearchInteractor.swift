import Foundation
import Services
import AnytypeCore

final class Legacy_ObjectTypeSearchInteractor {
    
    private let spaceId: String
    private let typesService: TypesServiceProtocol
    private let workspaceService: WorkspaceServiceProtocol
    private let showBookmark: Bool
    private let showSetAndCollection: Bool
    private let showFiles: Bool
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        spaceId: String,
        typesService: TypesServiceProtocol,
        workspaceService: WorkspaceServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        showBookmark: Bool,
        showSetAndCollection: Bool,
        showFiles: Bool
    ) {
        self.spaceId = spaceId
        self.typesService = typesService
        self.workspaceService = workspaceService
        self.showBookmark = showBookmark
        self.showSetAndCollection = showSetAndCollection
        self.showFiles = showFiles
        self.objectTypeProvider = objectTypeProvider
    }
    
}

extension Legacy_ObjectTypeSearchInteractor {
    
    func search(text: String) async throws -> [ObjectDetails] {
        try await typesService.searchObjectTypes(
            text: text, 
            includePins: true,
            includeLists: showSetAndCollection,
            includeBookmark: showBookmark, 
            includeFiles: showFiles,
            incudeNotForCreation: false,
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

