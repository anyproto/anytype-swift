import SwiftUI

struct DocumentSettingsListRow: View {
    
    let setting: DocumentSetting
    
    @Binding var pressed: Bool

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(spacing: 12) {
                setting.icon.frame(width: 44, height: 44)
                
                VStack(alignment: .leading) {
                    AnytypeText(setting.title, style: .bodyMedium)
                        .foregroundColor(.textPrimary)
                    AnytypeText(setting.subtitle, style: .caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if setting.isAvailable {
                    Image.arrow.frame(width: 24, height: 24)
                } else {
                    AnytypeText("Soon", style: .body)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .disabled(!setting.isAvailable)
    }
}

