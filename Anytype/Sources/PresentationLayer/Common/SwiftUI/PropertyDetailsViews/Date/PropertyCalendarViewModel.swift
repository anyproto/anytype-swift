import Combine
import Services
import Foundation

@MainActor
protocol PropertyCalendarOutput: AnyObject {
    func onOpenDateSelected(date: Date)
}

@MainActor
final class PropertyCalendarViewModel: ObservableObject {
    
    var date: Date
    @Published var dismiss = false
    
    let config: PropertyModuleConfiguration
    
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    private weak var output: (any PropertyCalendarOutput)?
    
    init(date: Date?, configuration: PropertyModuleConfiguration, output: (any PropertyCalendarOutput)?) {
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
            try await propertiesService.updateProperty(objectId: config.objectId, propertyKey: config.relationKey, value: value.protobufValue)
            let relationDetails = try propertyDetailsStorage.relationsDetails(key: config.relationKey, spaceId: config.spaceId)
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
