import SwiftUI

struct SetKanbanColumn: View {
    let headerRelation: Relation?
    let configurations: [SetContentViewItemConfiguration]

    var body: some View {
        VStack(spacing: 16) {
            header
            if configurations.isNotEmpty {
                column
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 16)
        .background(Color.shimmering)
        .cornerRadius(4)
        .frame(width: 270)
    }
    
    private var column: some View {
        VStack(spacing: 8) {
            ForEach(configurations) { configuration in
                SetGalleryViewCell(configuration: configuration)
            }
        }
        .frame(width: 250)
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
