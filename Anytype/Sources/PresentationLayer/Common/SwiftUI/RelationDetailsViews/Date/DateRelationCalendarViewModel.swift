import Combine
import Services
import Foundation

@MainActor
final class DateRelationCalendarViewModel: ObservableObject {
    
    var date: Date
    @Published var dismiss = false
    
    let config: RelationModuleConfiguration
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        self.date = date ?? Date()
        self.config = configuration
    }
    
    func dateChanged(_ newDate: Date) {
        let date = newDate.trimTime() ??  newDate
        let value = date.timeIntervalSince1970
        updateDateRelation(with: value)
    }
    
    func clear() {
        updateDateRelation(with: 0)
        dismiss.toggle()
    }
    
    private func updateDateRelation(with value: Double) {
        Task {
            try await relationsService.updateRelation(objectId: config.objectId, relationKey: config.relationKey, value: value.protobufValue)
            let relationDetails = try relationDetailsStorage.relationsDetails(for: config.relationKey, spaceId: config.spaceId)
            AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
                isEmpty: value.isZero,
                format: relationDetails.format,
                type: config.analyticsType,
                key: relationDetails.analyticsKey,
                spaceId: config.spaceId
            )
        }
    }
}
