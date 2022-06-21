import SwiftUI
import BlocksModels

struct SetFilterRow: View {
    
    @Environment(\.editMode) var editMode
    
    let configuration: SetFilterRowConfiguration
    let onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            content
        }
        .disabled(editMode?.wrappedValue != .inactive)
    }
    
    private var content: some View {
        HStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.backgroundSelected)
                Image.createImage(configuration.iconName)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium, color: .textPrimary)
                if let subtitle = configuration.subtitle, subtitle.isNotEmpty {
                    AnytypeText(subtitle, style: .relation1Regular, color: .textSecondary)
                }
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image.arrow
            }
        }
        .frame(height: 68)
    }
}
