import Combine
import Services

@MainActor
protocol RelationSelectedOptionsModelProtocol {
    var selectionMode: RelationSelectionOptionsMode { get }
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> { get }
    
    func onClear() async throws
    func optionSelected(_ optionId: String) async throws
    func removeRelationOption(_ optionId: String) async throws
    func removeRelationOptionFromSelectedIfNeeded(_ optionId: String) async throws
}

@MainActor
final class RelationSelectedOptionsModel: RelationSelectedOptionsModelProtocol {
    
    @Published private var selectedOptionsIds: [String] = []
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> { $selectedOptionsIds.eraseToAnyPublisher() }
    
    let selectionMode: RelationSelectionOptionsMode
    
    private let relationKey: String
    private let analyticsType: AnalyticsEventsRelationType
    private let relationsService: RelationsServiceProtocol
    
    init(
        selectionMode: RelationSelectionOptionsMode,
        selectedOptionsIds: [String],
        relationKey: String,
        analyticsType: AnalyticsEventsRelationType,
        relationsService: RelationsServiceProtocol
    ) {
        self.selectionMode = selectionMode
        self.selectedOptionsIds = selectedOptionsIds
        self.relationKey = relationKey
        self.analyticsType = analyticsType
        self.relationsService = relationsService
    }
    
    func onClear() async throws {
        selectedOptionsIds = []
        try await relationsService.updateRelation(relationKey: relationKey, value: nil)
        logChanges()
    }
    
    func optionSelected(_ optionId: String) async throws {
        switch selectionMode {
        case .single:
            selectedOptionsIds = [optionId]
        case .multi:
            handleMultiOptionSelected(optionId)
        }
        
        try await relationsService.updateRelation(
            relationKey: relationKey,
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
                relationKey: relationKey,
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
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: selectedOptionsIds.isEmpty, type: analyticsType)
    }
}
