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
    
    @State private var model: ObjectTypeWidgetViewModel
    
    init(info: ObjectTypeWidgetInfo, output: (any CommonWidgetModuleOutput)?) {
        self._model = State(wrappedValue: ObjectTypeWidgetViewModel(info: info, output: output))
    }
    
    var body: some View {
        WidgetSwipeActionView(
            isEnable: model.canCreateObject,
            showTitle: model.isExpanded,
            action: {
                WidgetSwipeTip().invalidate(reason: .actionPerformed)
                model.onCreateObject()
            }
        ) {
            LinkWidgetViewContainer(
                isExpanded: $model.isExpanded,
                dragId: model.typeId,
                homeState: model.canEdit ? .constant(.readwrite) : .constant(.readonly),
                createObjectAction: model.canCreateObject ? {
                    model.onCreateObject()
                } : nil,
                header: {
                    LinkWidgetDefaultHeader(title: model.typeName, icon: model.typeIcon, onTap: {
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
        .task(priority: .low) {
            await model.startSubscriptions()
        }
        .anytypeSheet(item: $model.deleteAlert) {
            ObjectTypeDeleteConfirmationAlert(data: $0)
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
            Divider()
        }
        
        if model.canDeleteType {
            Button(role: .destructive) {
                model.onDelete()
            } label: {
                Text(Loc.deleteObjectType)
                Image(systemName: "trash")
            }
        }
    }
}
