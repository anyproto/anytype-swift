import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    let viewModel: FlowRelationsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            header
            description
            featuredRelationsView
        }
    }

    private var header: some View {
        TitleWithIconView(
            icon: viewModel.icon,
            showIcon: viewModel.showIcon,
            canEditIcon: viewModel.canEditIcon,
            title: viewModel.title,
            showTitle: true,
            style: .list
        )
    }

    private var description: some View {
        Group {
            if let description = viewModel.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation3Regular
                )
                .foregroundColor(.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
            } else {
                EmptyView()
            }
        }
    }

    private var featuredRelationsView: some View {
        FeaturedRelationsView(
            relations: viewModel.relations,
            view: { relation in
                RelationValueView(
                    model: RelationValueViewModel(
                        relation:  RelationItemModel(relation: relation),
                        style: .setCollection,
                        mode: .button(action: nil)
                    )
                )
            }
        )
    }
}
