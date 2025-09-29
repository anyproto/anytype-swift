import SwiftUI
import AnytypeCore
import Services

enum ObjectTypeInfoViewMode {
    case create
    case edit
    case preview
    
    var isPreview: Bool {
        switch self {
        case .preview:
            return true
        case .edit, .create:
            return false
        }
    }
}

struct ObjectTypeInfo: Identifiable, Hashable {
    let singularName: String
    let pluralName: String
    let icon: CustomIcon?
    let color: CustomIconColor?
    let mode: ObjectTypeInfoViewMode
    
    var id: Int { hashValue }
}

struct ObjectTypeInfoView: View {
    @StateObject private var model: ObjectTypeInfoViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(info: ObjectTypeInfo, completion: @escaping (_ info: ObjectTypeInfo) -> ()) {
        _model = StateObject(wrappedValue: ObjectTypeInfoViewModel(info: info, completion: completion))
    }
    
    var body: some View {
        content
            .onAppear { model.dismiss = dismiss }
            .onChangeIfiOS17(of: model.name) { oldValue, newValue in
                model.onNameChange(old: oldValue, new: newValue)
            }
        
            .sheet(isPresented: $model.showIconPicker) {
                ObjectTypeIconPicker(isRemoveButtonAvailable: model.isRemoveIconButtonAvailable, onIconSelect: { icon, color in
                    model.onIconSelect(icon: icon, color: color)
                }, removeIcon: {
                    model.onIconDelete()
                })
            }
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            DragIndicator()
            Spacer.fixedHeight(12)
            title
            Spacer.fixedHeight(12)
            nameInput
            Spacer.fixedHeight(12)
            pluralNameInput
            Spacer.fixedHeight(12)
            button
            Spacer.fixedHeight(15)
        }
        .disabled(model.mode.isPreview)
        .padding(.horizontal, 16)
        .background(Color.Background.secondary)
    }

    private var nameInput: some View {
        HStack(alignment: .center, spacing: 0) {
            Button {
                model.onIconTap()
            } label: {
                IconView(icon: .object(model.objectIcon))
                    .frame(width: 32, height: 32)
            }
            Spacer.fixedWidth(10)
            AutofocusedTextField(placeholder: Loc.egProject, font: .heading, text: $model.name)
                .autocorrectionDisabled()
            Spacer()
            Spacer.fixedWidth(8)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
    
    private var pluralNameInput: some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                AnytypeText(Loc.typePluralName, style: .caption1Regular).foregroundColor(.Text.secondary)
                AnytypeTextField(placeholder: Loc.egProjects, font: .previewTitle1Regular, text: $model.pluralName)
                    .autocorrectionDisabled()
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
    
    private var title: some View {
        switch model.mode {
        case .create:
            AnytypeText(Loc.createNewType, style: .uxTitle1Semibold)
        case .edit:
            AnytypeText(Loc.editType, style: .uxTitle1Semibold)
        case .preview:
            AnytypeText(Loc.typeName, style: .uxTitle1Semibold)
        }
    }
    
    @ViewBuilder
    private var button: some View {
        switch model.mode {
        case .create:
            StandardButton(Loc.create, style: .primaryLarge) { model.onSaveTap() }
                .disabled(!model.isCreateButtonEnabled)
        case .edit:
            StandardButton(Loc.save, style: .primaryLarge) { model.onSaveTap() }
                .disabled(!model.isCreateButtonEnabled)
        case .preview:
            EmptyView()
        }
    }
}
