import SwiftUI
import UniformTypeIdentifiers

struct SetKanbanColumn: View {
    let subId: SubscriptionId
    let headerRelation: Relation?
    let configurations: [SetContentViewItemConfiguration]
    
    let dragAndDropDelegate: KanbanDragAndDropDelegate
    @State private var dropData = KanbanCardDropData()

    var body: some View {
        VStack(spacing: 13) {
            header
            if configurations.isNotEmpty {
                column
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 13)
        .padding(.bottom, 8)
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
                        dropData.fromSubId = subId
                        return NSItemProvider(object: configuration.id as NSString)
                    }
                    .onDrop(
                        of: [UTType.text],
                        delegate: KanbanCardDropInsideDelegate(
                            dragAndDropDelegate: dragAndDropDelegate,
                            droppingData: configuration,
                            toSubId: subId,
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
                AnytypeText("Uncategorized", style: .relation1Regular, color: .textSecondary)
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
    }
}
