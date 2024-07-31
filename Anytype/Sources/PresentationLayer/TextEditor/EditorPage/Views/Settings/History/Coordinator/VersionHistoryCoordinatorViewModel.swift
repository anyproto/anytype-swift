import Services
import SwiftUI

@MainActor
protocol VersionHistoryModuleOutput: AnyObject {
    func onVersionTap(_ versionId: String)
}

@MainActor
final class VersionHistoryCoordinatorViewModel: ObservableObject, VersionHistoryModuleOutput {
    
    let data: VersionHistoryData
    
    init(data: VersionHistoryData) {
        self.data = data
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(_ versionId: String) {
        // TODO
    }
}

