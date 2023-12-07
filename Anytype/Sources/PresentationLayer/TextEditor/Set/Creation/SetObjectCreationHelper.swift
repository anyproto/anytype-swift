import Services
import AnytypeCore

protocol SetObjectCreationHelperProtocol {
    func createObject(for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?, completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void))
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
        setting: ObjectCreationSetting?,
        completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void)
    ) {
        if isBookmarkObject(setDocument: setDocument, setting: setting) {
            completion(nil, nil)
        } else if setDocument.isCollection() {
            createObjectForCollection(for: setDocument, setting: setting, completion: completion)
        } else if setDocument.isRelationsSet() {
            createObjectForRelationSet(for: setDocument, setting: setting, completion: completion)
        } else {
            createObjectForRegularSet(for: setDocument, setting: setting, completion: completion)
        }
    }
    
    // MARK: - Private
    
    private func createObjectForCollection(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void)
    ) {
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId,
            completion: { details, blockId in
                Task { @MainActor [weak self] in
                    try await self?.objectActionsService.addObjectsToCollection(
                        contextId: setDocument.objectId,
                        objectIds: [details.id]
                    )
                    completion(details, blockId)
                }
            }
        )
    }
    
    private func createObjectForRelationSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void)
    ) {
        let relationsDetails = setDocument.dataViewRelationsDetails.filter { detail in
            guard let source = setDocument.details?.setOf else { return false }
            return source.contains(detail.id)
        }
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        
        createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: relationsDetails,
            templateId: templateId,
            completion: completion
        )
    }
    
    private func createObjectForRegularSet(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void)
    ) {
        let objectTypeId = setDocument.details?.setOf.first ?? ""
        let objectType = try? objectTypeProvider.objectType(id: objectTypeId)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId,
            completion: completion
        )
    }
    
    private func createObject(
        setDocument: SetDocumentProtocol,
        type: ObjectType?,
        relationsDetails: [RelationDetails],
        templateId: BlockId?,
        completion: ((_ details: ObjectDetails, _ blockId: String?) -> Void)?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let details = try await dataviewService.addRecord(
                typeUniqueKey: type?.uniqueKey,
                templateId: templateId ?? "",
                spaceId: setDocument.spaceId,
                details: prefilledFieldsBuilder.buildPrefilledFields(from: setDocument.activeViewFilters, relationsDetails: relationsDetails)
            )
            if FeatureFlags.setTextInFirstNoteBlock && type?.isNoteType ?? false {
                let model = try await blockActionsService.openForPreview(contextId: details.id)
                let firstTextBlockId = model.blocks.first {
                    guard let content = $0.content else { return false }
                    return BlocksModelsConverter.convert(middleware: content)?.isText ?? false
                }?.id
                completion?(details, firstTextBlockId)
            } else {
                completion?(details, nil)
            }
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
    func createObject(for setDocument: SetDocumentProtocol, completion: @escaping ((_ details: ObjectDetails?, _ blockId: String?) -> Void)) {
        createObject(for: setDocument, setting: nil, completion: completion)
    }
}
