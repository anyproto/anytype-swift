import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    let viewModel: FlowRelationsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            header
            description
            flowRelations
        }
    }

    private var header: some View {
        TitleWithIconView(
            icon: viewModel.icon,
            showIcon: viewModel.showIcon,
            title: viewModel.title,
            style: .list,
            onIconTap: viewModel.onIconTap
        )
    }

    private var description: some View {
        Group {
            if let description = viewModel.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation3Regular,
                    color: .Text.secondary
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var flowRelations: some View {
        if viewModel.relations.isNotEmpty {
            FlowLayout(
                items: viewModel.relations,
                alignment: .leading,
                spacing: .init(width: 6, height: 4),
                cell: { item, index in
                    HStack(spacing: 0) {
                        RelationValueView(
                            relation: RelationItemModel(relation: item),
                            style: .setCollection,
                            mode: .button(action: {
                                viewModel.onRelationTap(item)
                            })
                        )
                        if viewModel.relations.count - 1 > index {
                            dotImage
                        }
                    }
                }
            )
        } else {
            EmptyView()
        }
    }

    private var dotImage: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.Text.secondary)
            .frame(width: 3, height: 3)
    }
}
