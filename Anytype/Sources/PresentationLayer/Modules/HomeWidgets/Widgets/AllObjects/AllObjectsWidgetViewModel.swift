import Foundation
import Combine
import Services

@MainActor
final class AllObjectsWidgetViewModel: ObservableObject {
    
    @Injected(\.widgetActionsViewCommonMenuProvider)
    private var widgetActionsViewCommonMenuProvider: any WidgetActionsViewCommonMenuProviderProtocol
    
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
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: data.widgetObject,
            widgetBlockId: data.widgetBlockId,
            homeState: data.homeState.wrappedValue
        )
    }
}
