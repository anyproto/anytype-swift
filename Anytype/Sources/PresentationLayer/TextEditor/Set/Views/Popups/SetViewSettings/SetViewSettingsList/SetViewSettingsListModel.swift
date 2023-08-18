import SwiftUI

final class SetViewSettingsListModel: ObservableObject {
    @Published var name = ""
    
    let settings = SetViewSettings.allCases
    
    private weak var output: SetViewSettingsNavigationOutput?
    
    init(output: SetViewSettingsNavigationOutput?) {
        self.output = output
    }
    
    func onSettingTap(_ setting: SetViewSettings) {
        
    }
    
    func deleteView() {

    }
    
    func duplicateView() {

    }
}
