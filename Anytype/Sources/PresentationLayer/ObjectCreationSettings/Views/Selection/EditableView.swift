import SwiftUI

@MainActor
protocol ContextualMenuItemsProvider {
    @ViewBuilder
    var contextMenuItems: AnyView { get }
}

private enum Constaints {
    static let dotImageSize: CGFloat = 28
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
        .disabled(isEditing)
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
        Image(asset: ImageAsset.X24.more)
            .resizable()
            .frame(width: Constaints.dotImageSize, height: Constaints.dotImageSize)
            .foregroundColor(Color.Control.secondary)
            .background(Color.Background.highlightedMedium)
            .background(.ultraThinMaterial)
            .cornerRadius(Constaints.dotImageSize / 2)
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
