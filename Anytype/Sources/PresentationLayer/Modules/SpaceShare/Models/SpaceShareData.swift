import Foundation

struct SpaceShareData: Identifiable, Hashable {
    let spaceId: String
    let route: SettingsSpaceShareRoute
    var id: Int { hashValue }
}
