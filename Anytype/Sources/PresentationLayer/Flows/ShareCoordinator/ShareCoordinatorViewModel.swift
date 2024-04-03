import Foundation
import SwiftUI
import Services

@MainActor
final class ShareCoordinatorViewModel: ObservableObject, ShareOptionsModuleOutput {
    
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var showSearchObjectData: SearchModuleModel?
    @Published var showSpaceSearchData: SearchSpaceModel?
    @Published var dismiss = false
    
    init(
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.searchModuleAssembly = searchModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func searchSpaceModule(data: SearchSpaceModel) -> AnyView {
        return searchModuleAssembly.makeSpaceSearch(data: data)
    }
    
    func searchObjectModule(data: SearchModuleModel) -> AnyView {
        return searchModuleAssembly.makeObjectSearch(data: data)
    }
    
    // MARK: - ShareOptionsModuleOutput
    
    func onSpaceSelection(completion: @escaping (SpaceView) -> Void) {
        showSpaceSearchData = SearchSpaceModel(onSelect: completion)
    }
    
    func onDocumentSelection(data: SearchModuleModel) {
        showSearchObjectData = data
    }
}
