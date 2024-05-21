import Foundation
import SwiftUI

@MainActor
final class EditorCoordinatorViewModel: ObservableObject, WidgetObjectListCommonModuleOutput {
    
    var pageNavigation: PageNavigation?
    
    let data: EditorScreenData
    private let editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    
    init(
        data: EditorScreenData,
        editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    ) {
        self.data = data
        self.editorSetCoordinatorAssembly = editorSetCoordinatorAssembly
    }
    
    func makeSet(data: EditorSetObject) -> AnyView {
        editorSetCoordinatorAssembly.make(data: data)
    }
    
    // MARK: - WidgetObjectListCommonModuleOutput
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
}
