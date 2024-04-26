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
                    .foregroundColor(Color.Background.highlightedOfSelected)
                Image(asset: configuration.iconAsset)
                    .foregroundColor(.Button.active)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium, color: .Text.primary)
                AnytypeText(configuration.subtitle, style: .relation1Regular, color: .Text.secondary)
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image(asset: .arrowForward)
            }
        }
        .frame(height: 68)
    }
}
