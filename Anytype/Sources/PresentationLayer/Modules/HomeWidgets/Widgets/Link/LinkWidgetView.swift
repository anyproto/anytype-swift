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
    
    @StateObject private var model: LinkWidgetViewModel
    
    init(data: WidgetSubmoduleData) {
        self.data = data
        self._model = StateObject(wrappedValue: LinkWidgetViewModel(data: data))
    }
    
    var body: some View {
        WidgetContainerView(
            widgetBlockId: data.widgetBlockId,
            widgetObject: data.widgetObject,
            homeState: data.homeState,
            name: model.name,
            icon: model.icon,
            dragId: model.dragId,
            onCreateObjectTap: nil,
            onHeaderTap: {
                model.onHeaderTap()
            },
            output: data.output,
            content: { EmptyView() }
        )
    }
}
