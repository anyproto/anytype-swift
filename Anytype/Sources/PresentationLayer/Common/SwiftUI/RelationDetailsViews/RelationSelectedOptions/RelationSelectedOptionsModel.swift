import Combine
import Services

@MainActor
protocol RelationSelectedOptionsModelProtocol {
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> { get }
    func onClear() async throws
    func optionSelected(_ optionId: String) async throws
    func removeRelationOption(_ optionId: String) async throws
}

@MainActor
final class RelationSelectedOptionsModel: RelationSelectedOptionsModelProtocol {
    
    @Published private var selectedOptionsIds: [String] = []
    var selectedOptionsIdsPublisher: AnyPublisher<[String], Never> {
        $selectedOptionsIds.eraseToAnyPublisher()
    }
    
    private let mode: Mode
    private let relationKey: String
    private let analyticsType: AnalyticsEventsRelationType
    private let relationsService: RelationsServiceProtocol
    
    init(
        mode: Mode,
        selectedOptionsIds: [String],
        relationKey: String,
        analyticsType: AnalyticsEventsRelationType,
        relationsService: RelationsServiceProtocol
    ) {
        self.mode = mode
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
        switch mode {
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

extension RelationSelectedOptionsModel {
    enum Mode {
        case single
        case multi
    }
}
