import SwiftUI
import BlocksModels

struct SetSortRow: View {
    
    @Environment(\.editMode) var editMode
    
    let configuration: SetSortRowConfiguration
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
                    .foregroundColor(Color.BackgroundNew.highlightedOfSelected)
                Image(asset: configuration.iconAsset)
            }
            .frame(width: 48, height: 48)
            
            Spacer.fixedWidth(12)
            
            VStack(alignment: .leading, spacing: 2) {
                AnytypeText(configuration.title, style: .uxTitle2Medium, color: .TextNew.primary)
                AnytypeText(configuration.subtitle, style: .relation1Regular, color: .TextNew.secondary)
            }
            
            Spacer()
            
            if editMode?.wrappedValue == .inactive {
                Image(asset: .arrowForward)
            }
        }
        .frame(height: 68)
    }
}
