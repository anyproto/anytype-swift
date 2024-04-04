import Foundation
import SwiftUI
import Services

@MainActor
final class ShareCoordinatorViewModel: ObservableObject, ShareOptionsModuleOutput {
    
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    
    @Published var showSearchObjectData: ObjectSearchModuleData?
    @Published var showSpaceSearchData: SpaceSearchData?
    @Published var dismiss = false
        
    // MARK: - ShareOptionsModuleOutput
    
    func onSpaceSelection(completion: @escaping (SpaceView) -> Void) {
        showSpaceSearchData = SpaceSearchData(onSelect: completion)
    }
    
    func onDocumentSelection(data: ObjectSearchModuleData) {
        showSearchObjectData = data
    }
}
