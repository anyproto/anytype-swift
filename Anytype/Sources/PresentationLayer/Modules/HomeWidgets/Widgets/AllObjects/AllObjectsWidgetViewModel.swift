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
        AnytypeAnalytics.instance().logSelectHomeTab(source: .allObjects)
        data.output?.onObjectSelected(screenData: .editor(.allContent(spaceId: data.workspaceInfo.accountSpaceId)))
    }
    
    func onDeleteWidgetTap() {
        widgetActionsViewCommonMenuProvider.onDeleteWidgetTap(
            widgetObject: data.widgetObject,
            widgetBlockId: data.widgetBlockId,
            homeState: data.homeState.wrappedValue
        )
    }
}
