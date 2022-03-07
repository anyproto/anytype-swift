import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    @StateObject var viewModel: FlowRelationsViewModel

    var body: some View {
        FlowLayout(
            items: viewModel.relations,
            alignment: viewModel.alignment,
            cell: { item, index in
                HStack(spacing: 6) {
                    RelationValueView(relation: item, style: .featuredRelationBlock(allowMultiLine: false)) { relation in
                        viewModel.onRelationTap(relation)
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
