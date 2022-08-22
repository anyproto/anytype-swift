import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    let viewModel: FlowRelationsViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: viewModel.style.headerToRelationsOffset
        ) {
            header
            flowRelations
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            TitleWithIconView(
                icon: viewModel.icon,
                showIcon: viewModel.showIcon,
                title: viewModel.title,
                style: viewModel.style.titleStyle,
                onIconTap: viewModel.onIconTap
            )
            description
        }
    }
    
    private var description: some View {
        Group {
            if let description = viewModel.description, description.isNotEmpty {
                Spacer.fixedHeight(viewModel.style.descriptionOffset)
                AnytypeText(
                    description,
                    style: viewModel.style.descriptionFont,
                    color: viewModel.style.descriptionColor
                )
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                EmptyView()
            }
        }
    }
    
    private var flowRelations: some View {
        Group {
            if viewModel.relations.isNotEmpty {
                FlowLayout(
                    items: viewModel.relations,
                    alignment: .leading,
                    cell: { item, index in
                        HStack(spacing: 6) {
                            RelationValueView(
                                relation: RelationItemModel(relation: item),
                                style: .featuredRelationBlock(allowMultiLine: false))
                            {
                                viewModel.onRelationTap(item)
                            }

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
    }
    
    private var dotImage: some View {
        Image(systemName: "circle.fill")
            .resizable()
            .foregroundColor(.textSecondary)
            .frame(width: 3, height: 3)
    }
}
