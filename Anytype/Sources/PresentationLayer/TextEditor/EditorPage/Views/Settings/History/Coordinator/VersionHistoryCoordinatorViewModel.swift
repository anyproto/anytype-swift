import Services
import SwiftUI

@MainActor
@Observable
final class VersionHistoryCoordinatorViewModel:
    VersionHistoryModuleOutput,
    ObjectVersionModuleOutput
{

    var objectVersionData: ObjectVersionData?
    
    let data: VersionHistoryData
    
    private weak var output: (any ObjectVersionModuleOutput)?
    
    init(data: VersionHistoryData, output: (any ObjectVersionModuleOutput)?) {
        self.data = data
        self.output = output
    }
    
    // MARK: VersionHistoryModuleOutput
    
    func onVersionTap(title: String, icon: ObjectIcon?, versionId: String) {
        objectVersionData = ObjectVersionData(
            title: title,
            icon: icon,
            objectId: data.objectId, 
            spaceId: data.spaceId,
            versionId: versionId,
            isListType: data.isListType,
            canRestore: data.canRestore
        )
    }
    
    // MARK: ObjectVersionModuleOutput
    
    func versionRestored(_ text: String) {
        output?.versionRestored(text)
    }
}

