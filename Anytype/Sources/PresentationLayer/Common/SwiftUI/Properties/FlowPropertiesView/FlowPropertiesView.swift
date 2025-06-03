import SwiftUI
import AnytypeCore

struct FlowPropertiesView: View {
    let viewModel: FlowPropertiesViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            header
            description
            featuredPropertiesView
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

    private var featuredPropertiesView: some View {
        FeaturedPropertiesView(
            relations: viewModel.properties,
            view: { property in
                PropertyValueView(
                    model: PropertyValueViewModel(
                        property: PropertyItemModel(property: property),
                        style: .setCollection,
                        mode: .button(action: nil)
                    )
                )
            }
        )
    }
}
