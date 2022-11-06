import SwiftUI
import UniformTypeIdentifiers

struct SetKanbanColumn: View {
    let groupId: String
    let headerRelation: Relation?
    let configurations: [SetContentViewItemConfiguration]
    
    let dragAndDropDelegate: KanbanDragAndDropDelegate
    @Binding var dropData: KanbanCardDropData

    var body: some View {
        VStack(spacing: 0) {
            content
            if configurations.isEmpty {
                emptyDroppableArea
            }
        }
    }
    
    var content: some View {
        VStack(spacing: 0) {
            header
            column
        }
        .padding(.horizontal, 8)
        .padding(.bottom, configurations.isEmpty ? 0 : 8)
        .background(Color.shimmering)
        .cornerRadius(4)
        .frame(width: 270)
    }
    
    private var column: some View {
        VStack(spacing: 8) {
            ForEach(configurations) { configuration in
                SetGalleryViewCell(configuration: configuration)
                    .onDrag {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        dropData.draggingCard = configuration
                        dropData.initialFromGroupId = groupId
                        dropData.fromGroupId = groupId
                        return NSItemProvider(object: configuration.id as NSString)
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: KanbanCardDropInsideDelegate(
                            dragAndDropDelegate: dragAndDropDelegate,
                            droppingCard: configuration,
                            toGroupId: groupId,
                            data: $dropData
                        )
                    )
            }
        }
        .frame(width: 254)
    }
    
    private var header: some View {
        HStack(spacing: 0) {
            if let headerRelation {
                RelationValueView(
                    relation: RelationItemModel(relation: headerRelation),
                    style: .regular(allowMultiLine: false),
                    action: {}
                )
            } else {
                AnytypeText(
                    Loc.Set.View.Kanban.Column.Title.uncategorized,
                    style: .relation1Regular,
                    color: .textSecondary
                )
            }
            Spacer()
            Button {} label: {
                Image(asset: .more).foregroundColor(.buttonActive)
            }
            Spacer.fixedWidth(16)
            Button {} label: {
                Image(asset: .plus)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 44)
    }
    
    private var emptyDroppableArea: some View {
        Rectangle()
            .fill(Color.backgroundPrimary)
            .frame(height: 44)
            .onDrop(
                of: [UTType.text],
                delegate: KanbanCardDropInsideDelegate(
                    dragAndDropDelegate: dragAndDropDelegate,
                    droppingCard: nil,
                    toGroupId: groupId,
                    data: $dropData
                )
            )
    }
}
