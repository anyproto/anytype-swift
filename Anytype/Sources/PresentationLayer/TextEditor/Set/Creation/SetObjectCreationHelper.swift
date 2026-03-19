import Services

enum SetObjectCreationAction {
    case showObject(ObjectDetails, titleInputType: CreateObjectTitleInputType)
    case showBookmarkCreation(spaceId: String, collectionId: String?)
    case showChatCreation(spaceId: String, collectionId: String?)
}

protocol SetObjectCreationHelperProtocol: Sendable {
    func createObject(
        for setDocument: some SetDocumentProtocol, setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationAction
}

final class SetObjectCreationHelper: SetObjectCreationHelperProtocol, Sendable {
    
    private let dataviewService: any DataviewServiceProtocol = Container.shared.dataviewService()
    private let objectTypeProvider: any ObjectTypeProviderProtocol = Container.shared.objectTypeProvider()
    private let objectActionsService: any ObjectActionsServiceProtocol = Container.shared.objectActionsService()
    private let prefilledFieldsBuilder: any SetPrefilledFieldsBuilderProtocol = Container.shared.setPrefilledFieldsBuilder()
    private let blockService: any BlockServiceProtocol = Container.shared.blockService()
    
    // MARK: - SetObjectCreationHelperProtocol

    func createObject(
        for setDocument: some SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationAction {
        let collectionId = setDocument.isCollection() ? setDocument.objectId : nil

        if isBookmarkObject(setDocument: setDocument, setting: setting) {
            return .showBookmarkCreation(spaceId: setDocument.spaceId, collectionId: collectionId)
        } else if isChatObject(setDocument: setDocument, setting: setting) {
            return .showChatCreation(spaceId: setDocument.spaceId, collectionId: collectionId)
        } else if setDocument.isCollection() {
            return try await createObjectForCollection(for: setDocument, setting: setting)
        } else if setDocument.isSetByRelation() {
            return try await createObjectForRelationSet(for: setDocument, setting: setting)
        } else {
            return try await createObjectForRegularSet(for: setDocument, setting: setting)
        }
    }
    
    // MARK: - Private
    
    private func createObjectForCollection(
        for setDocument: some SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationAction {
        let objectType = objectType(for: setDocument, setting: setting)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)

        let result = try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )

        if case .showObject(let details, _) = result {
            try await objectActionsService.addObjectsToCollection(
                contextId: setDocument.objectId,
                objectIds: [details.id]
            )
        }

        return result
    }
    
    private func createObjectForRelationSet(
        for setDocument: some SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationAction {
        let relationsDetails = setDocument.dataViewRelationsDetails.filter { detail in
            guard let source = setDocument.details?.filteredSetOf else { return false }
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
        for setDocument: some SetDocumentProtocol,
        setting: ObjectCreationSetting?
    ) async throws -> SetObjectCreationAction {
        let objectTypeId = setDocument.details?.filteredSetOf.first ?? ""
        let objectType = try objectTypeProvider.objectType(id: objectTypeId)
        let templateId = setting?.templateId ?? defaultTemplateId(for: objectType, setDocument: setDocument)
        return try await createObject(
            setDocument: setDocument,
            type: objectType,
            relationsDetails: [],
            templateId: templateId
        )
    }
    
    private func createObject(
        setDocument: some SetDocumentProtocol,
        type: ObjectType?,
        relationsDetails: [PropertyDetails],
        templateId: String?
    ) async throws -> SetObjectCreationAction {
        let details = try await dataviewService.addRecord(
            typeUniqueKey: type?.uniqueKey,
            templateId: templateId ?? "",
            spaceId: setDocument.spaceId,
            details: prefilledFieldsBuilder.buildPrefilledFields(from: setDocument.activeViewFilters, relationsDetails: relationsDetails)
        )
        if let type, type.isNoteLayout {
            guard let newBlockId = try? await blockService.addFirstBlock(contextId: details.id, info: .emptyText) else {
                return .showObject(details, titleInputType: .none)
            }
            return .showObject(details, titleInputType: .writeToBlock(blockId: newBlockId))
        } else {
            return .showObject(details, titleInputType: .writeToRelationName)
        }
    }
    
    private func isBookmarkObject(setDocument: some SetDocumentProtocol, setting: ObjectCreationSetting?) -> Bool {
        if setDocument.isBookmarksSet() {
            return true
        }

        if let objectType = objectType(for: setDocument, setting: setting) {
            return objectType.recommendedLayout == .bookmark
        }

        return false
    }

    private func isChatObject(setDocument: some SetDocumentProtocol, setting: ObjectCreationSetting?) -> Bool {
        if setDocument.isChatSet() {
            return true
        }

        if let objectType = objectType(for: setDocument, setting: setting) {
            return objectType.isChatType
        }

        return false
    }
    
    private func objectType(for setDocument: some SetDocumentProtocol, setting: ObjectCreationSetting?) -> ObjectType? {
        let settingsObjectType = setting.map { try? objectTypeProvider.objectType(id: $0.objectTypeId) }
        let objectType = settingsObjectType ?? (try? setDocument.defaultObjectTypeForActiveView())
        return objectType
    }
    
    private func defaultTemplateId(for objectType: ObjectType?, setDocument: some SetDocumentProtocol) -> String {
        if let defaultTemplateId = setDocument.activeView.defaultTemplateID, defaultTemplateId.isNotEmpty {
            return defaultTemplateId
        } else {
            return objectType?.defaultTemplateId ?? ""
        }
    }
}

extension SetObjectCreationHelperProtocol {
    func createObject(for setDocument: some SetDocumentProtocol) async throws -> SetObjectCreationAction {
        return try await createObject(for: setDocument, setting: nil)
    }
}
