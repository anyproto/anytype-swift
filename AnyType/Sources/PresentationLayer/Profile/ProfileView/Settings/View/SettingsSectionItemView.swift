import SwiftUI

struct SettingsSectionItemView: View {
    let name: String
    let icon: Image
    
    @Binding var pressed: Bool

    var body: some View {
        Button(action: { pressed = true }) {
            HStack(spacing: 8) {
                icon.frame(width: 24.0, height: 24.0)
                AnytypeText(name, style: .headline).foregroundColor(.textPrimary)
                Spacer()
                Image.arrow
            }
        }
    }
}
