import Foundation
import SwiftUI

@MainActor
final class EditorCoordinatorViewModel: ObservableObject, WidgetObjectListCommonModuleOutput {
    
    var pageNavigation: PageNavigation?
    
    private let data: EditorScreenData
    private let widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol
    private let editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol
    private let editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    
    init(
        data: EditorScreenData,
        widgetObjectListModuleAssembly: WidgetObjectListModuleAssemblyProtocol,
        editorPageCoordinatorAssembly: EditorPageCoordinatorAssemblyProtocol,
        editorSetCoordinatorAssembly: EditorSetCoordinatorAssemblyProtocol
    ) {
        self.data = data
        self.widgetObjectListModuleAssembly = widgetObjectListModuleAssembly
        self.editorPageCoordinatorAssembly = editorPageCoordinatorAssembly
        self.editorSetCoordinatorAssembly = editorSetCoordinatorAssembly
    }
    
    func makeView() -> AnyView {
        switch data {
        case .favorites:
            return widgetObjectListModuleAssembly.makeFavorites(output: self)
        case .recentEdit:
            return widgetObjectListModuleAssembly.makeRecentOpen(output: self)
        case .recentOpen:
            return widgetObjectListModuleAssembly.makeRecentOpen(output: self)
        case .sets:
            return widgetObjectListModuleAssembly.makeSets(output: self)
        case .collections:
            return widgetObjectListModuleAssembly.makeCollections(output: self)
        case .bin:
            return widgetObjectListModuleAssembly.makeBin(output: self)
        case .page(let data):
            return editorPageCoordinatorAssembly.make(data: data)
        case .set(let data):
            return editorSetCoordinatorAssembly.make(data: data)
        }
    }
    
    // MARK: - WidgetObjectListCommonModuleOutput
    
    func onObjectSelected(screenData: EditorScreenData) {
        pageNavigation?.push(screenData)
    }
}
