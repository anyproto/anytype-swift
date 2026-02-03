import SwiftUI
import Services


struct RoundedButton: View {

    let text: String
    let textColor: Color
    let icon: ImageAsset?
    let decoration: RoundedButtonDecoration?
    let action: () -> Void

    var hasIcon: Bool { icon != nil }

    init(_ text: String, textColor: Color = .Text.primary, icon: ImageAsset? = nil, decoration: RoundedButtonDecoration? = nil, action: @escaping () -> Void) {
        self.text = text
        self.textColor = textColor
        self.icon = icon
        self.decoration = decoration
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            RoundedButtonView(text, textColor: textColor, icon: icon, decoration: decoration)
        }
    }
}

#Preview {
    SettingsSection {
        RoundedButton("Members", icon: .X24.member, decoration: .chevron) { }
            .settingsRow(showDivider: true, leadingPadding: 48)
        RoundedButton("Notifications", icon: .X24.unmuted, decoration: .caption("All")) { }
            .settingsRow(showDivider: false, leadingPadding: 48)
    }
    .padding()
}
