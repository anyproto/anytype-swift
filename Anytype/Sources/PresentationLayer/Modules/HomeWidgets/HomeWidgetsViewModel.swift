import Foundation
import AnytypeCore

@MainActor
final class HomeWidgetsViewModel: ObservableObject {

    private weak var output: HomeWidgetsModuleOutput?
    // TODO: Delete with onDisableNewHomeTap method
    private let navigationContext: NavigationContextProtocol
    
    init(widgeetObjectId: String, output: HomeWidgetsModuleOutput?, navigationContext: NavigationContextProtocol) {
        self.output = output
        self.navigationContext = navigationContext
    }
    
    func onDisableNewHomeTap() {
        FeatureFlags.update(key: .homeWidgets, value: false)
        output?.onOldHomeSelected()
    }
}
