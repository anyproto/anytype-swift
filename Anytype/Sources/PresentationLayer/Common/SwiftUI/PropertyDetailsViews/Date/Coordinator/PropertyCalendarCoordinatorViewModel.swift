import SwiftUI

@MainActor
@Observable
final class PropertyCalendarCoordinatorViewModel: PropertyCalendarOutput {

    let date: Date?
    let configuration: PropertyModuleConfiguration

    var dateObjectData: DateObjectData?
    
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
