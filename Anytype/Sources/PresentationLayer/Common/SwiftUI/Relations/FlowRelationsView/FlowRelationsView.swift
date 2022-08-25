import SwiftUI
import AnytypeCore

struct FlowRelationsView: View {
    let viewModel: FlowRelationsViewModel

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: viewModel.style.headerToContentOffset
        ) {
            header
            content
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: viewModel.style.relationsOffset) {
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
                style: viewModel.style.titleStyle,
                onIconTap: viewModel.onIconTap
            )
        }
    }
    
    private var description: some View {
        Group {
            if let description = viewModel.description, description.isNotEmpty {
                AnytypeText(
                    description,
                    style: viewModel.style.descriptionFont,
                    color: viewModel.style.descriptionColor
                )
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(viewModel.style.descriptionLineLimit)
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
                    spacing: viewModel.style.relationSpacing,
                    cell: { item, index in
                        HStack(spacing: viewModel.style.relationValueSpacing) {
                            RelationValueView(
                                relation: RelationItemModel(relation: item),
                                style: viewModel.style.relationStyle)
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
