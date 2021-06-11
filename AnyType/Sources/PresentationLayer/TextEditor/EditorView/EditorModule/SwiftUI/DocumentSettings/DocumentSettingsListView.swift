import SwiftUI

struct DocumentSettingsListView: View {

    @EnvironmentObject var viewModel: DocumentSettingsListViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            DocumentSettingsListRowView(
                icon: Image.ObjectSettings.icon,
                title: "Icon",
                subtitle: "Emoji or image for object",
                isAvailable: false,
                pressed: $viewModel.isIconSelected
            )
            .modifier(DividerModifier())
            
            DocumentSettingsListRowView(
                icon: Image.ObjectSettings.cover,
                title: "Cover",
                subtitle: "Background picture",
                isAvailable: false,
                pressed: $viewModel.isCoverSelected
            )
            .modifier(DividerModifier())
            
            DocumentSettingsListRowView(
                icon: Image.ObjectSettings.layout,
                title: "Layout",
                subtitle: "Arrangement of objects on a canvas",
                isAvailable: false,
                pressed: $viewModel.isLayoutSelected
            )
            .modifier(DividerModifier())
            
        }
        .padding([.leading, .trailing, .bottom], 16)
        .background(Color.background)
    }
}


struct DocumentSettingsListView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentSettingsListView()
            .previewLayout(.sizeThatFits)
    }
}

