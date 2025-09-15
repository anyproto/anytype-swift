import SwiftUI

struct ObjectTypeWidgetView: View {
    let info: ObjectTypeWidgetInfo
    let output: (any CommonWidgetModuleOutput)?
    
    var body: some View {
        ObjectTypeWidgetInternalView(info: info, output: output)
            .id(info.hashValue)
    }
}

private struct ObjectTypeWidgetInternalView: View {
    
    @StateObject private var model: ObjectTypeWidgetViewModel
    
    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self._model = StateObject(wrappedValue: ObjectTypeWidgetViewModel(info: info, output: output))
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
                menu: {
                    menu
                },
                content: {
                    content
                }
            )
        }
        .task {
            await model.startSubscriptions()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch model.rows {
        case .compactList(let rows):
            ListWidgetContentView(style: .compactList, rows: rows)
        case .gallery(let rows):
            GalleryWidgetView(rows: rows, onShowAllObjects: {
                model.onShowAllTap()
            })
        case .none:
            EmptyView()
        }

    }
    
    @ViewBuilder
    private var menu: some View {
        if model.canCreateObject {
            Button {
                model.onCreateObject()
            } label: {
                Text(Loc.new)
                Image(systemName: "square.and.pencil")
            }
        }
    }
}
