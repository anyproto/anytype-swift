import SwiftUI

struct DocumentSettingsListRowView: View {
    
    let icon: Image
    let title: String
    let subtitle: String
    
    let isAvailable: Bool
    
    @Binding var pressed: Bool

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(spacing: 12) {
                icon.frame(width: 44, height: 44)
                VStack(alignment: .leading) {
                    AnytypeText(title, style: .bodyMedium)
                        .foregroundColor(.textPrimary)
                    AnytypeText(subtitle, style: .caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if isAvailable {
                    Image.arrow.frame(width: 24, height: 24)
                } else {
                    AnytypeText("Soon", style: .body)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .disabled(isAvailable)
    }
}

