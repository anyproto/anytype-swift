import SwiftUI
import Services

struct SetObjectCreationSettingsView: View {
    // Popup height. Something is wrong with keyboard appearance on UIKit view. Intistic content size couldn't be calculated in FloatingPanel :/
    static let height: CGFloat = 480

    @ObservedObject var model: SetObjectCreationSettingsViewModel

    var body: some View {
        VStack {
            navigation
            if model.canChangeObjectType {
                objectTypeView
            }
            templatesView
            Spacer.fixedHeight(24)
        }
    }

    private var navigation: some View {
        ZStack {
            AnytypeText(Loc.createObject, style: .uxTitle1Semibold, color: .Text.primary)
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
                        style: .bodyRegular,
                        color: .Button.active
                    )
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

struct SetObjectCreationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SetObjectCreationSettingsView(
            model: .init(
                interactor: MockSetObjectCreationSettingsInteractor(),
                setDocument: MockSetDocument(),
                templatesService: TemplatesService(),
                toastPresenter: ToastPresenter(
                    viewControllerProvider: ViewControllerProvider(sceneWindow: UIWindow()),
                    keyboardHeightListener: KeyboardHeightListener(),
                    documentsProvider: ServiceLocator().documentsProvider
                ),
                onTemplateSelection: { _ in }
            )
        )
        .previewLayout(.sizeThatFits)
        .border(8, color: .Shape.primary)
        .padding()
        .previewDisplayName("Preview with title & icon")
    }
}
