import Services

protocol SetObjectCreationHandlerProtocol {
    func createObject(for setDocument: SetDocumentProtocol, setting: ObjectCreationSetting?, completion: @escaping ((_ details: ObjectDetails?) -> Void))
}

final class SetObjectCreationHandler: SetObjectCreationHandlerProtocol {
    
    private let dataviewService: DataviewServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let objectActionsService: ObjectActionsServiceProtocol
    
    init(
        objectTypeProvider: ObjectTypeProviderProtocol,
        dataviewService: DataviewServiceProtocol,
        objectActionsService: ObjectActionsServiceProtocol
    ) {
        self.objectTypeProvider = objectTypeProvider
        self.dataviewService = dataviewService
        self.objectActionsService = objectActionsService
    }
    
    func createObject(
        for setDocument: SetDocumentProtocol,
        setting: ObjectCreationSetting?,
        completion: @escaping ((_ details: ObjectDetails?) -> Void)
    ) {
        guard !setDocument.isBookmarksSet() else {
            completion(nil)
            return
        }
        
        if setDocument.isCollection() {
            let settingsObjectType = setting.map { try? objectTypeProvider.objectType(id: $0.objectTypeId) }
            let objectType = settingsObjectType ?? (try? setDocument.defaultObjectTypeForActiveView())
            let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
            
            createObject(
                setDocument: setDocument,
                type: objectType,
                relationsDetails: [],
                templateId: templateId,
                completion: { details in
                    Task { @MainActor [weak self] in
                        try await self?.objectActionsService.addObjectsToCollection(
                            contextId: setDocument.objectId,
                            objectIds: [details.id]
                        )
                        completion(details)
                    }
                }
            )
        } else if setDocument.isRelationsSet() {
            let relationsDetails = setDocument.dataViewRelationsDetails.filter { detail in
                guard let source = setDocument.details?.setOf else { return false }
                return source.contains(detail.id)
            }
            let settingsObjectType = setting.map { try? objectTypeProvider.objectType(id: $0.objectTypeId) }
            let objectType = settingsObjectType ?? (try? setDocument.defaultObjectTypeForActiveView())
            let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
            createObject(
                setDocument: setDocument,
                type: objectType,
                relationsDetails: relationsDetails,
                templateId: templateId,
                completion: completion
            )
        } else {
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
    }
    
    private func defaultTemplateId(for objectType: ObjectType?, setDocument: SetDocumentProtocol) -> String {
        if let defaultTemplateId = setDocument.activeView.defaultTemplateID, defaultTemplateId.isNotEmpty {
            return defaultTemplateId
        } else {
            return objectType?.defaultTemplateId ?? ""
        }
    }
    
    private func createObject(
        setDocument: SetDocumentProtocol,
        type: ObjectType?,
        relationsDetails: [RelationDetails],
        templateId: BlockId?,
        completion: ((_ details: ObjectDetails) -> Void)?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let details = try await self.dataviewService.addRecord(
                typeUniqueKey: type?.uniqueKey,
                templateId: templateId ?? "",
                spaceId: setDocument.spaceId,
                setFilters: setDocument.activeViewFilters,
                relationsDetails: relationsDetails
            )
            completion?(details)
        }
    }
}
