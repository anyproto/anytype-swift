import Foundation

struct HomePagePickerModuleData: Identifiable, Hashable {
    let spaceId: String

    var id: String { spaceId }
}
