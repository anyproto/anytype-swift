import SwiftUI
import Services

struct SetObjectCreationSettingsView: View {

    @StateObject private var model: SetObjectCreationSettingsViewModel
    
    init(data: SetObjectCreationData, output: (any SetObjectCreationSettingsOutput)?) {
        _model = StateObject(wrappedValue: SetObjectCreationSettingsViewModel(
            interactor: SetObjectCreationSettingsInteractor(setDocument: data.setDocument, viewId: data.viewId),
            data: data,
            output: output
        ))
    }

    var body: some View {
        VStack {
            DragIndicator()
            navigation
            if model.canChangeObjectType {
                objectTypeView
            }
            templatesView
            Spacer.fixedHeight(24)
        }
        .background(Color.Background.secondary)
        .snackbar(toastBarData: $model.toastData)
        .ignoresSafeArea(.keyboard)
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
            if model.templates.count > 1 || model.isEditingState {
                Button {
                    model.isEditingState.toggle()
                } label: {
                    AnytypeText(
                        model.isEditingState ? Loc.done : Loc.edit,
                        style: .bodyRegular
                    )
                    .foregroundColor(.Control.secondary)
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
        data: SetObjectCreationData(
            setDocument: Container.shared.documentsProvider().setDocument(objectId: "", spaceId: ""),
            viewId: "viewId",
            onTemplateSelection: { _ in }
        ),
        output: nil
    )
    .border(8, color: .Shape.primary)
    .padding()
}
