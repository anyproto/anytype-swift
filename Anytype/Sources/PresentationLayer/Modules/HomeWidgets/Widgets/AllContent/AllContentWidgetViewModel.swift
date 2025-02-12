import Foundation
import Combine
import Services

@MainActor
final class AllContentWidgetViewModel: ObservableObject {
    
    private let spaceId: String
    private weak var output: (any CommonWidgetModuleOutput)?
    
    init(spaceId: String, output: (any CommonWidgetModuleOutput)?) {
        self.spaceId = spaceId
        self.output = output
    }
    
    func onTapWidget() {
        output?.onObjectSelected(screenData: .editor(.allContent(spaceId: spaceId)))
    }
}
