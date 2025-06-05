import SwiftUI

@MainActor
final class PropertyCalendarCoordinatorViewModel: ObservableObject, PropertyCalendarOutput {
    
    let date: Date?
    let configuration: PropertyModuleConfiguration
    
    @Published var dateObjectData: DateObjectData?
    
    init(date: Date?, configuration: PropertyModuleConfiguration) {
        self.date = date
        self.configuration = configuration
    }
    
    // MARK: - PropertyCalendarOutput
    
    func onOpenDateSelected(date: Date) {
        dateObjectData = DateObjectData(
            data: EditorDateObject(
                date: date,
                spaceId: configuration.spaceId
            )
        )
    }
}

extension PropertyCalendarCoordinatorViewModel {
    struct DateObjectData: Identifiable {
        let id = UUID()
        let data: EditorDateObject
    }
}
