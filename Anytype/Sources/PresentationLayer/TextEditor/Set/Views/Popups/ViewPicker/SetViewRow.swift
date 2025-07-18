import SwiftUI
import Services

struct SetViewRow: View {
    @Environment(\.editMode) var editMode
    
    let configuration: SetViewRowConfiguration
    
    var body: some View {
        HStack(spacing: 5) {
            content
            editButton
        }
    }
    
    private var content: some View {
        Button(action: {
            configuration.onTap()
        }) {
            HStack(spacing: 0) {
                AnytypeText(
                    configuration.name,
                    style: .subheading
                )
                .foregroundColor(configuration.isActive ? .Text.primary : .Control.secondary)
                
                Spacer(minLength: 5)
                
                if !configuration.isSupported, editMode?.wrappedValue == .inactive {
                    AnytypeText(
                        Loc.EditorSet.View.Not.Supported.title,
                        style: .caption2Regular
                    ).foregroundColor(.Text.secondary)
                }
            }
        }
        .disabled(
            editMode?.wrappedValue != .inactive
        )
        .frame(height: 52)
    }
    
    private var editButton: some View {
        Group {
            if editMode?.wrappedValue == .active {
                Button(action: {
                    configuration.onEditTap()
                }) {
                    Image(asset: .X24.edit)
                        .foregroundColor(.Control.secondary)
                }
            }
        }
    }
}
