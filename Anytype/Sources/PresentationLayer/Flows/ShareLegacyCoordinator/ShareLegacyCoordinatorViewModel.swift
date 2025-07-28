import Foundation
import SwiftUI
import Services

@MainActor
final class ShareLegacyCoordinatorViewModel: ObservableObject, ShareLegacyOptionsModuleOutput {
    
    let spaceId: String
    @Published var showSearchObjectData: ObjectSearchModuleData?
    @Published var showSpaceSearchData: SpaceSearchData?
    @Published var dismiss = false
        
    // MARK: - ShareOptionsModuleOutput
    
    init(spaceId: String) {
        self.spaceId = spaceId
    }
    
    func onSpaceSelection(completion: @escaping (SpaceView) -> Void) {
        showSpaceSearchData = SpaceSearchData(onSelect: completion)
    }
    
    func onDocumentSelection(data: ObjectSearchModuleData) {
        showSearchObjectData = data
    }
}
