import Services
import SwiftUI

@MainActor
protocol VersionHistoryModuleOutput: AnyObject {
    func onVersionTap(title: String, versionId: String)
}

@MainActor
final class VersionHistoryCoordinatorViewModel: ObservableObject, VersionHistoryModuleOutput {
    
    @Published var objectVersionData: ObjectVersionData?
    
    let data: VersionHistoryData
    
    init(data: VersionHistoryData) {
        self.data = data
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(title: String, versionId: String) {
        objectVersionData = ObjectVersionData(
            title: title,
            objectId: data.objectId,
            versionId: versionId,
            isListType: data.isListType
        )
    }
}

