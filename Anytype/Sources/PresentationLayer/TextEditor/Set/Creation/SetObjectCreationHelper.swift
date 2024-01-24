import Services
import AnytypeCore

protocol SetObjectCreationHelperProtocol {
    func createObject(
        for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?
    ) async throws -> (ObjectDetails?, CreateObjectTitleInputType)
}

final class SetObjectCreationHelper: SetObjectCreationHelperProtocol {
    
    private let dataviewService: DataviewServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    private let prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol
    private let blockActionsService: BlockActionsServiceSingleProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        dataviewService: DataviewServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol,
        prefilledFieldsBuilder: SetPrefilledFieldsBuilderProtocol,
        blockActionsService: BlockActionsServiceSingleProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.dataviewService = dataviewService
        self.objectActionsService = objectActionsService
        self.prefilledFieldsBuilder = prefilledFieldsBuilder
        self.blockActionsService = blockActionsService
    }
    
    // MARK: - SetObjectCreationHelperProtocol
    
    func createObject(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> (ObjectDetails?, CreateObjectTitleInputType) {
        if isBookmarkObject(setDocument: setDocument, setting: setting) {
            return (nil, .none)
        } else if setDocument.isCollection() {
            return try await createObjectForCollection(for: setDocument, setting: setting)
        } else if setDocument.isRelationsSet() {
            return try await createObjectForRelationSet(for: setDocument, setting: setting)
        } else {
            return try await  createObjectForRegularSet(for: setDocument, setting: setting)
        }
    }
    
    // MARK: - Private
    
    private func createObjectForCollection(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> (ObjectDetails, CreateObjectTitleInputType) {
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        let (details, titleInputType) = try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )
        try await objectActionsService.addObjectsToCollection(
            contextId: setDocument.objectId,
            objectIds: [details.id]
        )
        
        return (details, titleInputType)
    }
    
    private func createObjectForRelationSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> (ObjectDetails, CreateObjectTitleInputType) {
        let relationsDetails = setDocument.dataViewRelationsDetails.filter { detail in
            guard let source = setDocument.details?.setOf else { return false }
            return source.contains(detail.id)
        }
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        return try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: relationsDetails,
            templateId: templateId
        )
    }
    
    private func createObjectForRegularSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> (ObjectDetails, CreateObjectTitleInputType) {
        let objectTypeId = setDocument.details?.setOf.first ?? ""
        let objectType = try? objectTypeProvider.objectType(id: objectTypeId)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        return try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )
    }
    
    private func createObject(
        setDocument: SetDocumentProtocol,
        type: ObjectType?,
        relationsDetails: [RelationDetails],
        templateId: BlockId?
    ) async throws -> (ObjectDetails, CreateObjectTitleInputType) {
        let details = try await dataviewService.addRecord(
            typeUniqueKey: type?.uniqueKey,
            templateId: templateId ?? "",
            spaceId: setDocument.spaceId,
            details: prefilledFieldsBuilder.buildPrefilledFields(from: setDocument.activeViewFilters, relationsDetails: relationsDetails)
        )
        let isNote = FeatureFlags.setTextInFirstNoteBlock && (type?.isNoteLayout ?? false)
        if isNote {
            guard let newBlockId = try await blockActionsService.add(contextId: details.id, targetId: EditorConstants.headerBlockId.rawValue, info: .emptyText, position: .bottom) else {
                return (details, .none)
            }
            
            return (details, .writeToBlock(blockId: newBlockId))
        } else {
            return (details, .writeToRelationName)
        }
    }
    
    private func isBookmarkObject(setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?) -> Bool {
        if setDocument.isBookmarksSet() {
            return true
        }
        
        if let objectType = objectType(for: setDocument, setting: setting) {
            return objectType.recommendedLayout == .bookmark
        }
        
        return false
    }
    
    private func objectType(for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?) -> ObjectType? {
        let settingsObjectType = setting.map { try? objectTypeProvider.objectType(id: $0.objectTypeId) }
        let objectType = settingsObjectType ?? (try? setDocument.defaultObjectTypeForActiveView())
        return objectType
    }
    
    private func defaultTemplateId(for objectType: ObjectType?, setDocument: SetDocumentProtocol) -> String {
        if let defaultTemplateId = setDocument.activeView.defaultTemplateID, defaultTemplateId.isNotEmpty {
            return defaultTemplateId
        } else {
            return objectType?.defaultTemplateId ?? ""
        }
    }
}

extension SetObjectCreationHelperProtocol {
    func createObject(for setDocument: SetDocumentProtocol) async throws -> (ObjectDetails?, CreateObjectTitleInputType) {
        return try await createObject(for: setDocument, setting: nil)
    }
}
