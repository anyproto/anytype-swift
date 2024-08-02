import Services
import SwiftUI

@MainActor
protocol VersionHistoryModuleOutput: AnyObject {
    func onVersionTap(title: String, icon: ObjectIcon?, versionId: String)
}

@MainActor
final class VersionHistoryCoordinatorViewModel: ObservableObject, VersionHistoryModuleOutput {
    
    @Published var objectVersionData: ObjectVersionData?
    
    let data: VersionHistoryData
    
    init(data: VersionHistoryData) {
        self.data = data
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(title: String, icon: ObjectIcon?, versionId: String) {
        objectVersionData = ObjectVersionData(
            title: title,
            icon: icon,
            objectId: data.objectId, 
            spaceId: data.spaceId,
            versionId: versionId,
            isListType: data.isListType
        )
    }
}

