import Foundation
import SwiftUI
import Services
import AnytypeCore

struct HomeWidgetSubmoduleView: View {

    let widgetInfo: BlockWidgetInfo
    let channelWidgetsObject: any BaseDocumentProtocol
    let personalWidgetsObject: any BaseDocumentProtocol
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
        case (.pinned, .tree):
            PinnedTreeWidgetsubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.pinned, .list):
            PinnedListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.pinned, .compactList):
            PinnedCompactListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recent, .tree):
            RecentEditTreeWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recent, .list):
            RecentEditListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recent, .compactList):
            RecentEditCompactListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recentOpen, .tree):
            RecentOpenTreeWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recentOpen, .list):
            RecentOpenListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case (.recentOpen, .compactList):
            RecentOpenCompactListWidgetSubmoduleView(data: widgetData(prefetchedDetails: nil))
        case _:
            EmptyView()
        }
    }

    @ViewBuilder
    private func viewForObject(_ objectDetails: ObjectDetails) -> some View {
        if objectDetails.isNotDeletedAndArchived {
            let data = widgetData(prefetchedDetails: objectDetails)
            switch (widgetInfo.fixedLayout, objectDetails.editorViewType) {
            case (.link, .page), (.link, .list), (.link, .type):
                LinkWidgetView(data: data)
            case (.tree, .page):
                ObjectTreeWidgetSubmoduleView(data: data)
            case (.view, .list), (.view, .type):
                SetObjectViewWidgetSubmoduleView(data: data)
            case (.list, .list), (.list, .type):
                SetObjectListWidgetSubmoduleView(data: data)
            case (.compactList, .list), (.compactList, .type):
                SetObjectCompactListWidgetSubmoduleView(data: data)
            default:
                // Fallback
                LinkWidgetView(data: data)
            }
        } else {
            EmptyView()
        }
    }

    private func widgetData(prefetchedDetails: ObjectDetails?) -> WidgetSubmoduleData {
        WidgetSubmoduleData(
            widgetBlockId: widgetInfo.id,
            channelWidgetsObject: channelWidgetsObject,
            personalWidgetsObject: personalWidgetsObject,
            homeState: $homeState,
            spaceInfo: workspaceInfo,
            output: output,
            prefetchedDetails: prefetchedDetails
        )
    }
}
