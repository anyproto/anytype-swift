import Combine
import Services
import Foundation

@MainActor
final class DateRelationCalendarViewModel: ObservableObject {
    
    @Published var date: Date
    @Published var dismiss = false
    
    let title: String
    private let objectId: String
    private let relationKey: String
    private let relationsService: RelationsServiceProtocol
    private let analyticsType: AnalyticsEventsRelationType
    
    init(
        title: String,
        date: Date?,
        objectId: String,
        relationKey: String,
        relationsService: RelationsServiceProtocol,
        analyticsType: AnalyticsEventsRelationType
    ) {
        self.title = title
        self.date = date ?? Date()
        self.objectId = objectId
        self.relationKey = relationKey
        self.relationsService = relationsService
        self.analyticsType = analyticsType
        
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
            try await relationsService.updateRelation(objectId: objectId, relationKey: relationKey, value: value.protobufValue)
            AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: value.isZero, type: analyticsType)
        }
    }
}
