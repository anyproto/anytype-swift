import Combine
import Services

@MainActor
protocol PropertySelectedOptionsModelProtocol {
    var config: PropertyModuleConfiguration { get }
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> { get }
    
    func onClear() async throws
    func optionSelected(_ optionId: String) async throws
    func removeRelationOption(_ optionId: String) async throws
    func removeRelationOptionFromSelectedIfNeeded(_ optionId: String) async throws
}

@MainActor
final class PropertySelectedOptionsModel: PropertySelectedOptionsModelProtocol {
    
    @Published private var selectedOptionsIds: [String] = []
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> { $selectedOptionsIds.eraseToAnyPublisher() }
    
    let config: PropertyModuleConfiguration
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    init(config: PropertyModuleConfiguration, selectedOptionsIds: [String]) {
        self.config = config
        self.selectedOptionsIds = selectedOptionsIds
    }
    
    func onClear() async throws {
        selectedOptionsIds = []
        try await relationsService.updateRelation(objectId: config.objectId, relationKey: config.relationKey, value: nil)
        logChanges()
    }
    
    func optionSelected(_ optionId: String) async throws {
        switch config.selectionMode {
        case .single:
            selectedOptionsIds = [optionId]
        case .multi:
            handleMultiOptionSelected(optionId)
        }
        
        try await relationsService.updateRelation(
            objectId: config.objectId,
            relationKey: config.relationKey,
            value: selectedOptionsIds.protobufValue
        )
        logChanges()
    }
    
    func removeRelationOption(_ optionId: String) async throws {
        try await relationsService.removeRelationOptions(ids: [optionId])
        try await removeRelationOptionFromSelectedIfNeeded(optionId)
    }
    
    func removeRelationOptionFromSelectedIfNeeded(_ optionId: String) async throws {
        if let index = selectedOptionsIds.firstIndex(of: optionId) {
            selectedOptionsIds.remove(at: index)
            try await relationsService.updateRelation(
                objectId: config.objectId,
                relationKey: config.relationKey,
                value: selectedOptionsIds.protobufValue
            )
        }
    }
    
    private func handleMultiOptionSelected(_ optionId: String) {
        if let index = selectedOptionsIds.firstIndex(of: optionId) {
            selectedOptionsIds.remove(at: index)
        } else {
            selectedOptionsIds.append(optionId)
        }
    }
    
    private func logChanges() {
        Task {
            let relationDetails = try propertyDetailsStorage.relationsDetails(key: config.relationKey, spaceId: config.spaceId)
            AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
                isEmpty: selectedOptionsIds.isEmpty,
                format: relationDetails.format,
                type: config.analyticsType,
                key: relationDetails.analyticsKey,
                spaceId: config.spaceId
            )
        }
    }
}
