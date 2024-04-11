import SwiftUI


struct SettingsButton: View {
    let text: String
    let textColor: Color
    let action: () -> ()
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                Spacer.fixedHeight(14)
                HStack(spacing: 0) {
                    AnytypeText(text, style: .uxBodyRegular)
                        .foregroundColor(textColor)
                    Spacer()
                }
                Spacer.fixedHeight(14)
            }
            .divider()
        }
    }
}

struct SettingsButton_Previews: PreviewProvider {
    static var previews: some View {
        SettingsButton(text: "Foo", textColor: .Text.primary, action: {})
    }
}
