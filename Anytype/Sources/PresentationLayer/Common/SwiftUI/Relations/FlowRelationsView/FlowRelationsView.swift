import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    let viewModel: FlowRelationsViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 4
        ) {
            header
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 2) {
            description
            flowRelations
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            TitleWithIconView(
                icon: viewModel.icon,
                showIcon: viewModel.showIcon,
                title: viewModel.title,
                style: .list,
                onIconTap: viewModel.onIconTap
            )
        }
    }

    private var description: some View {
        Group {
            if let description = viewModel.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: .relation3Regular,
                    color: .textSecondary
                )
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(1)
            } else {
                EmptyView()
            }
        }
    }

    private var flowRelations: some View {
        Group {
            if viewModel.relationValues.isNotEmpty {
                FlowLayout(
                    items: viewModel.relationValues,
                    alignment: .leading,
                    spacing: .init(width: 6, height: 2),
                    cell: { item, index in
                        HStack(spacing: 0) {
                            RelationValueView(
                                relation: RelationItemModel(relationValue: item),
                                style: .setCollection
                            ) {
                                viewModel.onRelationTap(item)
                            }

                            if viewModel.relationValues.count - 1 > index {
                                dotImage
                            }
                        }
                    }
                )
            } else {
                EmptyView()
            }
        }
    }

    private var dotImage: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.textSecondary)
            .frame(width: 3, height: 3)
    }
}
