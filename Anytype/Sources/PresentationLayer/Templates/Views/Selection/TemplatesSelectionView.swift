import SwiftUI
import Services

struct TemplatesSelectionView: View {

    @ObservedObject var model: TemplatesSelectionViewModel

    var body: some View {
        VStack(spacing: 8) {
            Spacer.fixedHeight(16)
            navigation
            Spacer.fixedHeight(14)
            collection
            Spacer.fixedHeight(24)
        }
    }

    var navigation: some View {
        ZStack {
            AnytypeText(Loc.TemplateSelection.selectTemplate, style: .uxTitle2Medium, color: .Text.primary)
            HStack(spacing: 0) {
                Button {
                    model.isEditingState.toggle()
                } label: {
                    AnytypeText(
                        model.isEditingState ? Loc.done : Loc.edit,
                        style: .calloutRegular,
                        color: .Button.active
                    )
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(asset: .X32.plus)
                        .tint(.Button.active)
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 12)
        }
    }
    
    var collection: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(model.templates) { item in
                    Button {
                        model.onModelTap(model: item)
                    } label: {
                        EditableView<TemplatePreview>(
                            content: TemplatePreview(viewModel: item),
                            onEditingTap: { model.onEditingButonTap(model: item) },
                            canBeEdited: item.isEditable,
                            isEditing: $model.isEditingState
                        )
                    }
                }
            }
            .frame(height: 232)
            .padding(.horizontal, 16)
        }
    }
}

struct TemplatesSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        TemplatesSelectionView(
            model: .init(
                interactor: MockTemplateSelectionInteractorProvider(),
                templatesService: TemplatesService(),
                onTemplateSelection: { _ in }
            )
        )
        .previewLayout(.sizeThatFits)
        .border(8, color: .Stroke.primary)
        .padding()
        .previewDisplayName("Preview with title & icon")
    }
}
