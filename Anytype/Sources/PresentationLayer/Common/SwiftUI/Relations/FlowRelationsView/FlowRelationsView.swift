import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    @ObservedObject var viewModel: FlowRelationsViewModel

    var body: some View {
        FlowLayout(
            items: viewModel.relations,
            alignment: viewModel.alignment,
            cell: { item, index in
                HStack(spacing: 6) {
                    RelationValueView(relation: RelationItemModel(relation: item), style: .featuredRelationBlock(allowMultiLine: false)) {
                        viewModel.onRelationTap(item)
                    }

                    if viewModel.relations.count - 1 > index {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .foregroundColor(.textSecondary)
                            .frame(width: 3, height: 3)
                    }
                }
            }
        )
    }
}
