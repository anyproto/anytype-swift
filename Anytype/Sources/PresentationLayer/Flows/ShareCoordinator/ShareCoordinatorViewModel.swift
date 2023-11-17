import Foundation
import SwiftUI
import Services

@MainActor
final class ShareCoordinatorViewModel: ObservableObject {
    
    private let shareModuleAssembly: ShareModuleAssemblyProtocol
    private let searchModuleAssembly: SearchModuleAssemblyProtocol
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var showSearchData: SearchModuleModel?
    @Published var showSpaceSearchData: SearchSpaceModel?
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
        return shareModuleAssembly.make { [weak self] arg in
            self?.showSearchData = arg
        } onSpaceSearch: { [weak self] handler in
            self?.showSpaceSearchData = .init(onSelect: handler)
        } onClose: { [weak self] arg in
            self?.dismiss.toggle()
        }
    }
    
    func searchSpaceModule(data: SearchSpaceModel) -> AnyView {
        return searchModuleAssembly.makeSpaceSearch(data: data)
    }
    
    func searchModule(data: SearchModuleModel) -> AnyView {
        return searchModuleAssembly.makeObjectSearch(data: data)
    }
}
