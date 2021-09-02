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
                AnytypeText(name, style: .uxBodyRegular, color: .textPrimary)
                Spacer()
                if comingSoon {
                    AnytypeText("Soon", style: .uxCalloutRegular, color: .textTertiary)
                } else {
                    Image.arrow.frame(width: 24, height: 24)
                }
            }
        }
        .disabled(comingSoon)
    }
}
