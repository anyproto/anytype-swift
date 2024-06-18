import Foundation
import SwiftUI
import Services

struct HomeWidgetSubmoduleView: View {
    
    let widgetInfo: BlockWidgetInfo
    let widgetObject: BaseDocumentProtocol
    @Binding var homeState: HomeWidgetsState
    let output: CommonWidgetModuleOutput?
    
    var body: some View {
        switch widgetInfo.source {
        case .object(let objectDetails):
            viewForObject(objectDetails)
        case .library(let anytypeWidgetId):
            viewForAnytypeWidgetId(anytypeWidgetId)
        }
    }
    
    @ViewBuilder
    private func viewForAnytypeWidgetId(_ anytypeWidgetId: AnytypeWidgetId) -> some View {
        switch (anytypeWidgetId, widgetInfo.fixedLayout) {
        case (.favorite, .tree):
            FavoriteTreeWidgetsubmoduleView(data: widgetData)
        case (.favorite, .list):
            FavoriteListWidgetSubmoduleView(data: widgetData)
        case (.favorite, .compactList):
            FavoriteCompactListWidgetSubmoduleView(data: widgetData)
        case (.recent, .tree):
            RecentEditTreeWidgetSubmoduleView(data: widgetData)
        case (.recent, .list):
            RecentEditListWidgetSubmoduleView(data: widgetData)
        case (.recent, .compactList):
            RecentEditCompactListWidgetSubmoduleView(data: widgetData)
        case (.recentOpen, .tree):
            RecentOpenTreeWidgetSubmoduleView(data: widgetData)
        case (.recentOpen, .list):
            RecentOpenListWidgetSubmoduleView(data: widgetData)
        case (.recentOpen, .compactList):
            RecentOpenCompactListWidgetSubmoduleView(data: widgetData)
        case (.sets, .tree):
            SetsCompactListWidgetSubmoduleView(data: widgetData)
        case (.sets, .list):
            SetsListWidgetSubmoduleView(data: widgetData)
        case (.sets, .compactList):
            SetsCompactListWidgetSubmoduleView(data: widgetData)
        case (.collections, .tree):
            CollectionsCompactListWidgetSubmoduleView(data: widgetData)
        case (.collections, .list):
            CollectionsListWidgetSubmoduleView(data: widgetData)
        case (.collections, .compactList):
            CollectionsCompactListWidgetSubmoduleView(data: widgetData)
        case (_, .link):
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func viewForObject(_ objectDetails: ObjectDetails) -> some View {
        if objectDetails.isNotDeletedAndVisibleForEdit {
            switch widgetInfo.fixedLayout {
            case .link:
                LinkWidgetView(data: widgetData)
            case .tree:
                if objectDetails.editorViewType == .page {
                    ObjectTreeWidgetSubmoduleView(data: widgetData)
                } else {
                    // Fallback
                    LinkWidgetView(data: widgetData)
                }
            case .list:
                if objectDetails.editorViewType == .set {
                    SetObjectListWidgetSubmoduleView(data: widgetData)
                } else {
                    // Fallback
                    LinkWidgetView(data: widgetData)
                }
            case .compactList:
                if objectDetails.editorViewType == .set {
                    SetObjectCompactListWidgetSubmoduleView(data: widgetData)
                } else {
                    LinkWidgetView(data: widgetData)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private var widgetData: WidgetSubmoduleData {
        WidgetSubmoduleData(widgetBlockId: widgetInfo.id, widgetObject: widgetObject, homeState: $homeState, output: output)
    }
}
