import Foundation
import SwiftUI

protocol EditorCoordinatorAssemblyProtocol {
    @MainActor
    func make(data: EditorScreenData) -> AnyView
}

final class EditorCoordinatorAssembly: EditorCoordinatorAssemblyProtocol {
    
    private let coordinatorsID: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    
    init(coordinatorsID: CoordinatorsDIProtocol, modulesDI: ModulesDIProtocol) {
        self.coordinatorsID = coordinatorsID
        self.modulesDI = modulesDI
    }
    
    // MARK: - EditorCoordinatorAssemblyProtocol
    
    @MainActor
    func make(data: EditorScreenData) -> AnyView {
        // TODO: Navigation: Fix widget object list output
        switch data {
        case .favorites:
            return modulesDI.widgetObjectList().makeFavorites(bottomPanelManager: nil, output: nil)
        case .recentEdit:
            return modulesDI.widgetObjectList().makeRecentOpen(bottomPanelManager: nil, output: nil)
        case .recentOpen:
            return modulesDI.widgetObjectList().makeRecentOpen(bottomPanelManager: nil, output: nil)
        case .sets:
            return modulesDI.widgetObjectList().makeSets(bottomPanelManager: nil, output: nil)
        case .collections:
            return modulesDI.widgetObjectList().makeCollections(bottomPanelManager: nil, output: nil)
        case .bin:
            return modulesDI.widgetObjectList().makeBin(bottomPanelManager: nil, output: nil)
        case .page(let data):
            return coordinatorsID.editorPage().make(data: data)
        case .set(let data):
            return coordinatorsID.editorSet().make(data: data)
        }
    }
}

