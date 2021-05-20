import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let icon: Image
    let comingSoon: Bool
    
    @Binding var pressed: Bool

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(spacing: 8) {
                icon.frame(width: 28.0, height: 28.0)
                AnytypeText(name, style: .headline).foregroundColor(.textPrimary)
                Spacer()
                if comingSoon {
                    AnytypeText("Soon", style: .body).foregroundColor(.textTertiary)
                } else {
                    Image.arrow
                }
            }
        }
        .disabled(comingSoon)
    }
}
