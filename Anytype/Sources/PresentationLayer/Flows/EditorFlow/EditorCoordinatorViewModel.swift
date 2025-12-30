import Foundation
import SwiftUI

@MainActor
@Observable
final class EditorCoordinatorViewModel: WidgetObjectListCommonModuleOutput {
    
    var pageNavigation: PageNavigation?
    
    let data: EditorScreenData
    
    init(data: EditorScreenData) {
        self.data = data
    }
    
    // MARK: - WidgetObjectListCommonModuleOutput
    
    func onObjectSelected(screenData: ScreenData) {
        pageNavigation?.open(screenData)
    }
}
