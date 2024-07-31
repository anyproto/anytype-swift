import Services
import SwiftUI

@MainActor
protocol VersionHistoryModuleOutput: AnyObject {
    func onVersionTap(title: String, objectId: String, versionId: String)
}

@MainActor
final class VersionHistoryCoordinatorViewModel: ObservableObject, VersionHistoryModuleOutput {
    
    @Published var objectVersionData: ObjectVersionData?
    
    let data: VersionHistoryData
    
    init(data: VersionHistoryData) {
        self.data = data
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(title: String, objectId: String, versionId: String) {
        objectVersionData = ObjectVersionData(title: title, objectId: objectId, versionId: versionId)
    }
}

