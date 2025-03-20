import SwiftUI
import AnytypeCore
import Services


struct NewTypeCreationView: View {
    @StateObject private var model: NewTypeCreationViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(name: String, completion: @escaping (_ name: String, _ pluralName: String, _ icon: CustomIcon?, _ color: CustomIconColor?) -> ()) {
        _model = StateObject(wrappedValue: NewTypeCreationViewModel(name: name, completion: completion))
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
            AnytypeText(Loc.createNewType, style: .uxTitle1Semibold)
            Spacer.fixedHeight(12)
            nameInput
            Spacer.fixedHeight(12)
            pluralNameInput
            Spacer.fixedHeight(12)
            StandardButton(Loc.create, style: .primaryLarge) { model.onSaveTap() }
            Spacer.fixedHeight(15)
        }
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
            AnytypeTextField(placeholder: Loc.name, font: .heading, text: $model.name)
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
                AnytypeText(Loc.pluralName, style: .caption1Regular).foregroundColor(.Text.secondary)
                AnytypeTextField(placeholder: Loc.name, font: .previewTitle1Regular, text: $model.pluralName)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
}
