import Foundation
import SwiftUI
import Services

@MainActor
final class ShareCoordinatorViewModel: ObservableObject {
    
    private let shareModuleAssembly: ShareModuleAssemblyProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var showSearchData: SearchModuleModel?
    @Published var dismiss = false
    
    init(
        shareModuleAssembly: ShareModuleAssemblyProtocol,
        searchModuleAssembly: SearchModuleAssemblyProtocol,
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    ) {
        self.shareModuleAssembly = shareModuleAssembly
        self.searchModuleAssembly = searchModuleAssembly
        self.activeWorkspaceStorage = activeWorkspaceStorage
    }
    
    func shareModule() -> AnyView? {
        return shareModuleAssembly.make { [weak self, activeWorkspaceStorage] arg in
            self?.showSearchData = SearchModuleModel(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                title: arg.0,
                layoutLimits: arg.1,
                onSelect: arg.2
            )
        } onClose: { [weak self] arg in
            self?.dismiss.toggle()
        }
    }
    
    func searchModule(data: SearchModuleModel) -> AnyView {
        return searchModuleAssembly.makeObjectSearch(data: data)
    }
}
