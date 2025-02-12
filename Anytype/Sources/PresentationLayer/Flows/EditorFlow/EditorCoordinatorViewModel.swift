import Foundation
import SwiftUI

@MainActor
final class EditorCoordinatorViewModel: ObservableObject, WidgetObjectListCommonModuleOutput {
    
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
