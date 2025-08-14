import SwiftUI
import Services

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
        FlowPropertiesView(
            viewModel: FlowPropertiesViewModel(
                icon: configuration.icon,
                showIcon: configuration.showIcon, 
                canEditIcon: configuration.canEditIcon,
                title: configuration.title,
                description: configuration.description,
                properties: configuration.relations.filter {
                    $0.hasValue && $0.key != BundledPropertyKey.description.rawValue
                }
            )
        )
        .background(Color.Background.primary)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.vertical, 20)
        .clipped()
        .fixTappableArea()
    }
}
