import SwiftUI

struct ObjectTypeWidgetView: View {
    let info: ObjectTypeWidgetInfo
    
    var body: some View {
        ObjectTypeWidgetInternalView(info: info)
            .id(info.hashValue)
    }
}

private struct ObjectTypeWidgetInternalView: View {
    
    @StateObject private var model: ObjectTypeWidgetViewModel
    
    init(info: ObjectTypeWidgetInfo) {
        self._model = StateObject(wrappedValue: ObjectTypeWidgetViewModel(info: info))
    }
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: model.canCreateObject,
            showTitle: model.isExpanded,
            action: {
                if #available(iOS 17.0, *) {
                    WidgetSwipeTip().invalidate(reason: .actionPerformed)
                }
                model.onCreateObject()
            }
        ) {
            LinkWidgetViewContainer(
                isExpanded: $model.isExpanded,
                homeState: .constant(.readwrite),
                header: {
                    LinkWidgetDefaultHeader(title: model.typeName, icon: nil, onTap: {
                        model.onHeaderTap()
                    })
                },
                content: {
                    content
                }
            )
        }
        .task {
            await model.startSubscription()
        }
    }
    
    private var content: some View {
        EmptyView()
    }
}
