import SwiftUI


struct SetKanbanColumn: View {
    let groupId: String
    let headerType: SetKanbanColumnHeaderType
    let configurations: [SetContentViewItemConfiguration]
    let isGroupBackgroundColors: Bool
    let backgroundColor: BlockBackgroundColor
    let showPagingView: Bool
    
    let dragAndDropDelegate: any SetDragAndDropDelegate
    @Binding var dropData: SetCardDropData
    
    let onShowMoreTap: () -> Void
    let onSettingsTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            content
            if configurations.isEmpty {
                emptyDroppableArea
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            header
            column
        }
        .padding(.horizontal, 8)
        .padding(.bottom, configurations.isEmpty ? 0 : 8)
        .background(
            isGroupBackgroundColors ?
            backgroundColor.swiftColor.opacity(0.5) :
            Color.Background.primary
        )
        .cornerRadius(4)
        .frame(width: 270)
    }
    
    private var column: some View {
        VStack(spacing: 8) {
            ForEach(configurations) { configuration in
                SetDragAndDropView(
                    dropData: $dropData,
                    configuration: configuration,
                    groupId: groupId,
                    dragAndDropDelegate: dragAndDropDelegate,
                    content: {
                        SetGalleryViewCell(configuration: configuration)
                    }
                )
            }
            if showPagingView {
                pagingView
            }
        }
        .frame(width: 254)
    }
    
    private var header: some View {
        Button {
            onSettingsTap()
        } label: {
            headerContent
                .fixTappableArea()
        }
        .frame(height: 44)
        .buttonStyle(LightDimmingButtonStyle())
    }
    
    private var headerContent: some View {
        HStack(spacing: 0) {
            switch headerType {
            case .uncategorized:
                AnytypeText(
                    Loc.Set.View.Kanban.Column.Title.uncategorized,
                    style: .relation2Regular
                )
                .foregroundColor(.Text.secondary)
            case let .status(options):
                StatusPropertyView(options: options, hint: "", style: .kanbanHeader)
            case let .tag(options):
                TagPropertyView(tags: options, hint: "", style: .kanbanHeader)
            case let .checkbox(title, isChecked):
                HStack(spacing: 6) {
                    if isChecked {
                        Image(asset: .TextEditor.Text.checked)
                    } else {
                        Image(asset: .TextEditor.Text.unchecked)
                            .foregroundColor(.Control.active)
                    }
                    let text = isChecked ?
                    Loc.Set.View.Kanban.Column.Title.checked(title) :
                    Loc.Set.View.Kanban.Column.Title.unchecked(title)
                    AnytypeText(
                        text,
                        style: .relation2Regular
                    )
                    .foregroundColor(.Text.secondary)
                }
            }
            
            Spacer()
            
            Image(asset: .X24.more).foregroundColor(.Control.active)
        }
        .padding(.horizontal, 10)
    }
    
    private var pagingView: some View {
        Button {
            onShowMoreTap()
        } label: {
            VStack(spacing: 0) {
                Spacer.fixedHeight(4)
                HStack(spacing: 0) {
                    Spacer.fixedWidth(3)
                    Image(asset: .arrowDown)
                        .foregroundColor(.Text.secondary)
                        .frame(width: 18, height: 18)
                    Spacer.fixedWidth(7)
                    AnytypeText(
                        Loc.Set.View.Kanban.Column.Paging.Title.showMore,
                        style: .caption1Medium
                    )
                    .foregroundColor(.Text.secondary)
                    Spacer()
                }
                Spacer.fixedHeight(4)
            }
        }
    }
    
    private var emptyDroppableArea: some View {
        SetDragAndDropView(
            dropData: $dropData,
            configuration: nil,
            groupId: groupId,
            dragAndDropDelegate: dragAndDropDelegate,
            content: {
                Rectangle()
                    .fill(Color.Background.primary)
                    .frame(height: 44)
            }
        )
    }
}
