import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetSubmoduleView: View {
    
    let widgetInfo: BlockWidgetInfo
    let widgetObject: any BaseDocumentProtocol
    let workspaceInfo: AccountInfo
    @Binding var homeState: HomeWidgetsState
    let output: (any CommonWidgetModuleOutput)?
    
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
        case (.allObjects, _):
            if FeatureFlags.allObjectsFromLibrary {
                AllObjectsWidgetView(data: widgetData)
            } else {
                EmptyView()
            }
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
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                SetsCompactListWidgetSubmoduleView(data: widgetData)
            }
        case (.sets, .list):
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                SetsListWidgetSubmoduleView(data: widgetData)
            }
        case (.sets, .compactList):
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                SetsCompactListWidgetSubmoduleView(data: widgetData)
            }
        case (.collections, .tree):
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                CollectionsCompactListWidgetSubmoduleView(data: widgetData)
            }
        case (.collections, .list):
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                CollectionsListWidgetSubmoduleView(data: widgetData)
            }
        case (.collections, .compactList):
            if FeatureFlags.objectTypeWidgets {
                EmptyView()
            } else {
                CollectionsCompactListWidgetSubmoduleView(data: widgetData)
            }
        case (.bin, _):
            if FeatureFlags.binWidgetFromLibrary {
                BinWidgetView(data: widgetData)
            } else {
                EmptyView()
            }
        case _:
            EmptyView()
        }
    }
        
    @ViewBuilder
    private func viewForObject(_ objectDetails: ObjectDetails) -> some View {
        if objectDetails.isNotDeletedAndArchived {
            switch (widgetInfo.fixedLayout, objectDetails.editorViewType) {
            case (.link, .page), (.link, .list), (.link, .type):
                LinkWidgetView(data: widgetData)
            case (.tree, .page):
                ObjectTreeWidgetSubmoduleView(data: widgetData)
            case (.view, .list), (.view, .type):
                SetObjectViewWidgetSubmoduleView(data: widgetData)
            case (.list, .list), (.list, .type):
                SetObjectListWidgetSubmoduleView(data: widgetData)
            case (.compactList, .list), (.compactList, .type):
                SetObjectCompactListWidgetSubmoduleView(data: widgetData)
            default:
                // Fallback
                LinkWidgetView(data: widgetData)
            }
        } else {
            EmptyView()
        }
    }
    
    private var widgetData: WidgetSubmoduleData {
        WidgetSubmoduleData(widgetBlockId: widgetInfo.id, widgetObject: widgetObject, homeState: $homeState, workspaceInfo: workspaceInfo, output: output)
    }
}
