import SwiftUI
import Services

struct SetObjectCreationSettingsView: View {
    // Popup height. Something is wrong with keyboard appearance on UIKit view. Intistic content size couldn't be calculated in FloatingPanel :/
    static let height: CGFloat = 480

    @StateObject private var model: SetObjectCreationSettingsViewModel
    
    init(setDocument: SetDocumentProtocol, viewId: String, output: SetObjectCreationSettingsOutput?) {
        _model = StateObject(wrappedValue: SetObjectCreationSettingsViewModel(
            interactor: SetObjectCreationSettingsInteractor(setDocument: setDocument, viewId: viewId),
            setDocument: setDocument,
            output: output
        ))
    }

    var body: some View {
        VStack {
            navigation
            if model.canChangeObjectType {
                objectTypeView
            }
            templatesView
            Spacer.fixedHeight(24)
        }
        .snackbar(toastBarData: $model.toastData)
    }

    private var navigation: some View {
        ZStack {
            AnytypeText(Loc.createObject, style: .uxTitle1Semibold)
                .foregroundColor(.Text.primary)
            if model.isTemplatesEditable {
                navigationButton
            }
        }
        .frame(height: 48)
    }
    
    private var navigationButton: some View {
        HStack(spacing: 0) {
            if model.templates.count > 2 || model.isEditingState {
                Button {
                    model.isEditingState.toggle()
                } label: {
                    AnytypeText(
                        model.isEditingState ? Loc.done : Loc.edit,
                        style: .bodyRegular
                    )
                    .foregroundColor(.Button.active)
                }
                Spacer()
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 12)
    }
    
    private var objectTypeView: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.TemplateSelection.ObjectType.subtitle)
                .padding(.horizontal, 16)
            Spacer.fixedHeight(4)
            objectTypesCollection
        }
    }

    private var objectTypesCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.objectTypes) { model in
                    InstalledObjectTypeView(model: model)
                }
            }
            .frame(height: 48)
            .padding(.horizontal, 16)
            .padding(.vertical, 1)
        }
    }
    
    private var templatesView: some View {
        VStack(spacing: 0) {
            SectionHeaderView(title: Loc.TemplateSelection.Template.subtitle)
                .padding(.horizontal, 16)
            Spacer.fixedHeight(4)
            templatesCollection
        }
    }
    
    private var templatesCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(model.templates) { item in
                    EditableView<TemplatePreview>(
                        content: TemplatePreview(viewModel: item),
                        onTap: { model.onTemplateTap(model: item.model) },
                        canBeEdited: item.model.isEditable,
                        isEditing: $model.isEditingState
                    )
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 232)
        }
    }
}

#Preview {
    SetObjectCreationSettingsView(
        setDocument: Container.shared.documentsProvider().setDocument(objectId: "", forPreview: false, inlineParameters: nil),
        viewId: "viewId",
        output: nil
    )
    .previewLayout(.sizeThatFits)
    .border(8, color: .Shape.primary)
    .padding()
    .previewDisplayName("Preview with title & icon")
}
