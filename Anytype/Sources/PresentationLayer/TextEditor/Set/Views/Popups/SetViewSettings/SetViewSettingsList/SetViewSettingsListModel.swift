import SwiftUI

final class SetViewSettingsListModel: ObservableObject {
    private weak var output: SetViewSettingsNavigationOutput?
    
    init(output: SetViewSettingsNavigationOutput?) {
        self.output = output
    }
}
