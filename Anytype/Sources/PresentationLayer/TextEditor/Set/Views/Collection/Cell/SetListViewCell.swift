import SwiftUI
import BlocksModels

struct SetListViewCell: View {
    let configuration: SetContentViewItemConfiguration
    
    var body: some View {
        Button {
            configuration.onItemTap()
        } label: {
            content
        }
        .buttonStyle(LightDimmingButtonStyle())
    }
    
    private var content: some View {
        FlowRelationsView(
            viewModel: FlowRelationsViewModel(
                icon: configuration.icon,
                showIcon: configuration.showIcon,
                title: configuration.title,
                description: configuration.description,
                relations: configuration.relations.filter {
                    $0.hasValue && $0.id != BundledRelationKey.description.rawValue
                },
                onIconTap: configuration.onIconTap,
                onRelationTap: { _ in }
            )
        )
        .background(Color.BackgroundNew.primary)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 20)
        .clipped()
        .contentShape(Rectangle())
    }
}
