import Foundation
import Services
import AnytypeCore

struct SpaceNotificationsSettingsModuleData: Identifiable, Hashable {
    let spaceId: String
    var id: Int { hashValue }
}

@MainActor
final class SpaceNotificationsSettingsViewModel: ObservableObject {
    
    private let data: SpaceNotificationsSettingsModuleData
    
    @Published var state = SpaceNotificationsSettingsState.allActiviy
    @Published var dismiss = false
    
    init(data: SpaceNotificationsSettingsModuleData) {
        self.data = data
    }
    
    func onStateChange(_ state: SpaceNotificationsSettingsState) {
        // TODO: implement when middle is ready
        self.state = state
    }
}
