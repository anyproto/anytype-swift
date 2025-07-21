import SwiftUI
import Services

struct SetSortRow: View {
    
    @Environment(\.editMode) var editMode
    
    let configuration: SetSortRowConfiguration
    
    var body: some View {
        Button {
            configuration.onTap()
        } label: {
            content
        }
        .disabled(editMode?.wrappedValue != .inactive)
    }
    
    private var content: some View {
        HStack {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.Background.highlightedMedium)
                Image(asset: configuration.iconAsset)
                    .foregroundColor(.Control.secondary)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium)
                    .foregroundColor(.Text.primary)
                AnytypeText(configuration.subtitle, style: .relation1Regular)
                    .foregroundColor(.Text.secondary)
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image(asset: .RightAttribute.disclosure)
            }
        }
        .frame(height: 68)
    }
}
