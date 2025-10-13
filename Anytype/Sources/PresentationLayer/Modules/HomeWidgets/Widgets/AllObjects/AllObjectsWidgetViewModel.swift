import Foundation
import Combine
import Services

@MainActor
final class AllObjectsWidgetViewModel: ObservableObject {
    
    let data: WidgetSubmoduleData
    var dragId: String { data.widgetBlockId }
    
    init(data: WidgetSubmoduleData) {
        self.data = data
    }
    
    func onHeaderTap() {
        guard let info = data.widgetObject.widgetInfo(blockId: data.widgetBlockId) else { return }
        AnytypeAnalytics.instance().logClickWidgetTitle(source: .allObjects, createType: info.widgetCreateType)
        data.output?.onObjectSelected(screenData: .editor(.allObjects(spaceId: data.workspaceInfo.accountSpaceId)))
    }
}
