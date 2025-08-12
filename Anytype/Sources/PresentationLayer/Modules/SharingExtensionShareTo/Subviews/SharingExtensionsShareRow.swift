import SwiftUI

struct SharingExtensionsShareRowData: Identifiable {
    let objectId: String
    let icon: Icon
    let title: String
    let subtitle: String?
    let selected: Bool
    
    var id: String { objectId }
}

struct SharingExtensionsShareRow: View {
    
    let data: SharingExtensionsShareRowData
    
    var body: some View {
        HStack(spacing: 12) {
            IconView(icon: data.icon)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading) {
                Text(data.title)
                    .anytypeStyle(.uxTitle2Medium)
                    .foregroundStyle(Color.Text.primary)
                
                if let subtitle = data.subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .anytypeFontStyle(.caption1Regular)
                        .foregroundStyle(Color.Text.secondary)
                }
            }
            
            Spacer()
            
            AnytypeCircleCheckbox(checked: data.selected)
        }
        .frame(height: 72)
        .newDivider()
        .padding(.horizontal, 16)
    }
}
