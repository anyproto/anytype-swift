import SwiftUI
import BlocksModels

struct EditorSetViewRow: View {
    @Environment(\.editMode) var editMode
    
    let configuration: EditorSetViewRowConfiguration
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 5) {
            content
            editButton
        }
    }
    
    private var content: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.name,
                    style: .uxBodyRegular,
                    color: configuration.isSupported ? .textPrimary : .textSecondary
                )
                Spacer(minLength: 5)
                accessoryView
            }
        }
        .disabled(
            editMode?.wrappedValue != .inactive ||
            !configuration.isSupported
        )
        .frame(height: 52)
    }
    
    private var accessoryView: some View {
        Group {
            if configuration.isSupported {
                if configuration.isActive, editMode?.wrappedValue == .inactive {
                    Image(asset: .optionChecked)
                        .foregroundColor(.Button.selected)
                }
            } else {
                if editMode?.wrappedValue == .inactive {
                    AnytypeText(
                        Loc.EditorSetViewPicker.View.Available.soon(configuration.typeName),
                        style: .uxBodyRegular,
                        color: .textSecondary
                    )
                }
            }
        }
    }
    
    private var editButton: some View {
        Group {
            if editMode?.wrappedValue == .active {
                Button(action: {
                    configuration.onEditTap()
                }) {
                    Image(asset: .setPenEdit)
                        .foregroundColor(.Button.selected)
                }
            }
        }
    }
}
