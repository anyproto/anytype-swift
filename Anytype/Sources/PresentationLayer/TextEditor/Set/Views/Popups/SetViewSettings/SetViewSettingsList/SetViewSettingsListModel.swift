import SwiftUI

@MainActor
final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    
    let settings = SetViewSettings.allCases
    
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    init(output: SetViewSettingsCoordinatorOutput?) {
        self.output = output
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        switch setting {
        case .defaultObject:
            output?.onDefaultObjectTap()
        case .layout:
            output?.onLayoutTap()
        case .relations:
            output?.onRelationsTap()
        case .filters:
            output?.onFiltersTap()
        case .sorts:
            output?.onSortsTap()
        }
    }
    
    func deleteView() {

    }
    
    func duplicateView() {

    }
}
