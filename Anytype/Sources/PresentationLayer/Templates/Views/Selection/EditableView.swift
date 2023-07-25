import SwiftUI

protocol ContextualMenuItemsProvider {
    @ViewBuilder
    var contextMenuItems: AnyView { get }
}

struct EditableView<Content: View & ContextualMenuItemsProvider>: View {
    var content: Content
    var onTap: () -> Void
    var canBeEdited: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        Button {
            onTap()
        } label: {
            content
        }
            .padding(.trailing, 8)
            .padding(.top, 8)
            .if(canBeEdited && isEditing) {
                $0.overlay(dotImageButton, alignment: .topTrailing)
            }
    }
    
    var dotImageButton: some View {
        Menu {
            content.contextMenuItems
        } label: {
            dotImage
        }
    }
    
    var dotImage: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .light))
                .cornerRadius(14)
                .background(Color.Additional.editingBackground.opacity(0.51))
                .frame(width: 24, height: 24)
                .cornerRadius(14)
            Image(asset: ImageAsset.X24.more)
                .foregroundColor(Color.Button.active)
                
        }
    }
}

struct EditableView_Previews: PreviewProvider {
    static var previews: some View {
        EditableView<TemplatePreview>(
            content: TemplatePreview(
                viewModel: TemplatePreviewViewModel(
                    model: MockTemplatePreviewModel.iconCoverTitle.model,
                    onOptionSelection: { _ in }
                )
            ),
            onTap: {},
            canBeEdited: true,
            isEditing: .constant(true)
        )
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Preview with title & icon")
    }
}
