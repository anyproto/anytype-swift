import Combine
import Services
import Foundation

@MainActor
final class DateRelationCalendarViewModel: ObservableObject {
    
    @Published var date: Date
    @Published var dismiss = false
    
    let config: RelationModuleConfiguration
    
    @Injected(\.relationsService)
    private var relationsService: RelationsServiceProtocol
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        self.date = date ?? Date()
        self.config = configuration
        
        if date.isNil {
            dateChanged()
        }
    }
    
    func dateChanged() {
        let date = date.trimTime() ??  date
        let value = date.timeIntervalSince1970
        updateDateRelation(with: value)
    }
    
    func onQuickOptionTap(_ option: DateRelationCalendarQuickOption) {
        date =  option.date
        dateChanged()
    }
    
    func clear() {
        updateDateRelation(with: 0)
        dismiss.toggle()
    }
    
    private func updateDateRelation(with value: Double) {
        Task {
            try await relationsService.updateRelation(objectId: config.objectId, relationKey: config.relationKey, value: value.protobufValue)
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: value.isZero, type: config.analyticsType)
        }
    }
}
