import Combine
import Services
import Foundation

@MainActor
protocol RelationCalendarOutput: AnyObject {
    func onOpenDateSelected(date: Date)
}

@MainActor
final class RelationCalendarViewModel: ObservableObject {
    
    var date: Date
    @Published var dismiss = false
    
    let config: RelationModuleConfiguration
    
    @Injected(\.relationsService)
    private var relationsService: any RelationsServiceProtocol
    @Injected(\.relationDetailsStorage)
    private var relationDetailsStorage: any RelationDetailsStorageProtocol
    
    private weak var output: (any RelationCalendarOutput)?
    
    init(date: Date?, configuration: RelationModuleConfiguration, output: (any RelationCalendarOutput)?) {
        self.date = date ?? Date()
        self.config = configuration
        self.output = output
        let value = self.date.timeIntervalSince1970
        updateDateRelation(with: value)
    }
    
    func dateChanged(_ newDate: Date) {
        let date = newDate.trimTime() ??  newDate
        let value = date.timeIntervalSince1970
        self.date = newDate
        updateDateRelation(with: value)
    }
    
    func clear() {
        updateDateRelation(with: 0)
        dismiss.toggle()
    }
    
    func onOpenCurrentDateSelected() {
        output?.onOpenDateSelected(date: date)
    }
    
    private func updateDateRelation(with value: Double) {
        Task {
            try await relationsService.updateRelation(objectId: config.objectId, relationKey: config.relationKey, value: value.protobufValue)
            let relationDetails = try relationDetailsStorage.relationsDetails(key: config.relationKey, spaceId: config.spaceId)
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
