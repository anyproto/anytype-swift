import Foundation
import SwiftUI

struct LinkWidgetView: View {
    
    let data: WidgetSubmoduleData
    
    var body: some View {
        LinkWidgetInternalView(data: data)
            .id(data.widgetBlockId)
    }
}

struct LinkWidgetInternalView: View {

    let data: WidgetSubmoduleData

    @State private var model: LinkWidgetViewModel

    init(data: WidgetSubmoduleData) {
        self.data = data
        _model = State(initialValue: LinkWidgetViewModel(data: data))
    }

    var body: some View {
        WidgetContainerView(
            widgetBlockId: data.widgetBlockId,
            channelWidgetsObject: data.channelWidgetsObject,
            personalWidgetsObject: data.personalWidgetsObject,
            spaceId: data.spaceInfo.accountSpaceId,
            homeState: data.homeState,
            name: model.name,
            icon: model.icon,
            badgeModel: model.badgeModel,
            parentBadge: model.parentBadge,
            dragId: model.dragId,
            onCreateObjectTap: nil,
            onHeaderTap: {
                model.onHeaderTap()
            },
            output: data.output,
            content: { EmptyView() }
        )
        .task {
            await model.startSubscriptions()
        }
    }
}
