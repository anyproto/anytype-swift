import Foundation
import SwiftUI
import Services

@MainActor
final class ShareCoordinatorViewModel: ObservableObject, ShareOptionsModuleOutput {
    
    private let shareOptionsModuleAssembly: ShareOptionsModuleAssemblyProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var showSearchObjectData: SearchModuleModel?
    @Published var showSpaceSearchData: SearchSpaceModel?
    @Published var dismiss = false
    
    init(
        shareOptionsModuleAssembly: ShareOptionsModuleAssemblyProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.shareOptionsModuleAssembly = shareOptionsModuleAssembly
        self.searchModuleAssembly = searchModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func shareModule() -> AnyView {
        shareOptionsModuleAssembly.make(output: self)
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
