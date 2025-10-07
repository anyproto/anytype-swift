import SwiftUI

struct SharingExtensionsChatRowData {
    let title: String
    let selected: Bool
}

struct SharingExtensionsChatRow: View {
        
    let data: SharingExtensionsChatRowData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(asset: .X24.chat)
                .frame(width: 48, height: 48)
                .foregroundStyle(Color.Control.primary)
            
            Text(data.title)
                .anytypeStyle(.uxTitle2Medium)
                .foregroundStyle(Color.Text.primary)
            
            Spacer()
            
            AnytypeCircleCheckbox(checked: data.selected)
        }
        .frame(height: 72)
        .newDivider()
        .padding(.horizontal, 16)
    }
}
