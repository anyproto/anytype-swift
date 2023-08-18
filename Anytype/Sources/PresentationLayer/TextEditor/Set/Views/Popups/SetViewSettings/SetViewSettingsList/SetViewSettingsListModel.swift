import SwiftUI

final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    
    let settings = SetViewSettings.allCases
    
    private weak var output: SetViewSettingsCoordinatorOutput?
    
    init(output: SetViewSettingsCoordinatorOutput?) {
        self.output = output
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        
    }
    
    func deleteView() {

    }
    
    func duplicateView() {

    }
}
