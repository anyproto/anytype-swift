import SwiftUI
import AnytypeCore
import Services

enum NewTypeCreationViewMode {
    case create
    case edit
}

struct NewTypeCreationView: View {
    @StateObject private var model: NewTypeCreationViewModel
    @Environment(\.dismiss) private var dismiss
    private let mode: NewTypeCreationViewMode
    
    init(name: String, pluralName: String = "", mode: NewTypeCreationViewMode, completion: @escaping (_ name: String, _ pluralName: String, _ icon: CustomIcon?, _ color: CustomIconColor?) -> ()) {
        _model = StateObject(wrappedValue: NewTypeCreationViewModel(name: name, pluralName: pluralName, completion: completion))
        self.mode = mode
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
            button
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
            AnytypeTextField(placeholder: Loc.puzzle, font: .heading, text: $model.name)
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
                AnytypeTextField(placeholder: Loc.puzzles, font: .previewTitle1Regular, text: $model.pluralName)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .border(16, color: .Shape.primary, lineWidth: 0.5)
    }
    
    private var button: some View {
        switch mode {
        case .create:
            StandardButton(Loc.create, style: .primaryLarge) { model.onSaveTap() }
        case .edit:
            StandardButton(Loc.save, style: .primaryLarge) { model.onSaveTap() }
        }
    }
}
