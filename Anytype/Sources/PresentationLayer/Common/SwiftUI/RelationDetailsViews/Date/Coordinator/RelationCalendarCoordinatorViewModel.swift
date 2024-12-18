import SwiftUI

@MainActor
final class RelationCalendarCoordinatorViewModel: ObservableObject, RelationCalendarOutput {
    
    let date: Date?
    let configuration: RelationModuleConfiguration
    
    @Published var dateObjectData: DateObjectData?
    
    init(date: Date?, configuration: RelationModuleConfiguration) {
        self.date = date
        self.configuration = configuration
    }
    
    // MARK: - RelationCalendarOutput
    
    func onOpenDateSelected(date: Date) {
        dateObjectData = DateObjectData(
            data: EditorDateObject(
                date: date,
                spaceId: configuration.spaceId
            )
        )
    }
}

extension RelationCalendarCoordinatorViewModel {
    struct DateObjectData: Identifiable {
        let id = UUID()
        let data: EditorDateObject
    }
}
