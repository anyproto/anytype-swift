import SwiftUI

struct FlowRelationsView: View {
    @StateObject var viewModel: FlowRelationsViewModel

    var body: some View {
        FlowLayout(
            items: viewModel.relations,
            alignment: viewModel.alignment,
            cell: { item, index in
                Button {
                    viewModel.onRelationTap(item)
                } label: {
                    HStack(spacing: 6) {
                        RelationValueViewProvider.relationView(item, style: .featuredRelationBlock(allowMultiLine: false))

                        if viewModel.relations.count - 1 > index {
                            Image(systemName: "circle.fill")
                                .resizable()
                                .foregroundColor(.textSecondary)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
        )
    }
}
